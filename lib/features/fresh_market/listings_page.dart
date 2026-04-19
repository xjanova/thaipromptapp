import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/text_styles.dart';
import '../../core/theme/tokens.dart';
import '../../shared/models/fresh_market.dart';
import 'fresh_market_repository.dart';
import 'widgets/listing_card.dart';

/// Browse + search listings, optionally pre-filtered by `categoryId`.
///
/// Implementation notes:
/// - Pagination is keep-on-load — appends to a single growing list.
/// - Search input debounces 350ms before re-fetching.
/// - Category filter chip lives in the AppBar so the user always sees what's
///   active.
class TaladsodListingsPage extends ConsumerStatefulWidget {
  const TaladsodListingsPage({super.key, this.initialCategoryId});

  final int? initialCategoryId;

  @override
  ConsumerState<TaladsodListingsPage> createState() =>
      _TaladsodListingsPageState();
}

class _TaladsodListingsPageState extends ConsumerState<TaladsodListingsPage> {
  final _searchCtl = TextEditingController();
  final _scrollCtl = ScrollController();
  Timer? _debounce;

  int? _categoryId;
  String _search = '';
  String _sort = 'newest';
  bool _organicOnly = false;

  final List<TmListing> _items = [];
  int _page = 1;
  int _lastPage = 1;
  bool _loading = false;
  bool _initialError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.initialCategoryId;
    _scrollCtl.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    _scrollCtl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollCtl.hasClients) return;
    if (_loading || _page >= _lastPage) return;
    if (_scrollCtl.position.pixels <
        _scrollCtl.position.maxScrollExtent - 600) return;
    _load();
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      if (reset) {
        _page = 1;
        _initialError = false;
        _errorMessage = null;
      }
    });
    try {
      final repo = await ref.read(freshMarketRepositoryProvider.future);
      final result = await repo.listings(
        page: reset ? 1 : _page + 1,
        categoryId: _categoryId,
        search: _search.isEmpty ? null : _search,
        organicOnly: _organicOnly,
        sort: _sort,
      );
      if (!mounted) return;
      setState(() {
        if (reset) _items.clear();
        _items.addAll(result.items);
        _page = result.currentPage;
        _lastPage = result.lastPage;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _initialError = reset && _items.isEmpty;
        _errorMessage = '$e';
      });
    }
  }

  void _onSearchChanged(String v) {
    _search = v.trim();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _load(reset: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TpColors.paper,
      appBar: AppBar(
        backgroundColor: TpColors.paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('ตลาดสด · ค้นหา'),
        titleTextStyle: TpText.titleLg.copyWith(color: TpColors.ink),
        iconTheme: const IconThemeData(color: TpColors.ink),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchCtl,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'ค้นหา ผัก ผลไม้ เนื้อสัตว์ ...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: TpColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TpRadii.button),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
          _FilterRow(
            sort: _sort,
            organicOnly: _organicOnly,
            categoryId: _categoryId,
            onSortChanged: (s) {
              setState(() => _sort = s);
              _load(reset: true);
            },
            onOrganicToggled: (v) {
              setState(() => _organicOnly = v);
              _load(reset: true);
            },
            onClearCategory: () {
              setState(() => _categoryId = null);
              _load(reset: true);
            },
          ),
          Expanded(
            child: _initialError
                ? _ErrorState(
                    message: _errorMessage ?? '',
                    onRetry: () => _load(reset: true),
                  )
                : RefreshIndicator(
                    color: TpColors.leaf,
                    onRefresh: () => _load(reset: true),
                    child: GridView.builder(
                      controller: _scrollCtl,
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.66,
                      ),
                      itemCount: _items.length + (_loading ? 2 : 0),
                      itemBuilder: (_, i) {
                        if (i >= _items.length) {
                          return Container(
                            decoration: BoxDecoration(
                              color: TpColors.card,
                              borderRadius:
                                  BorderRadius.circular(TpRadii.medium),
                              boxShadow: TpShadows.claySm,
                            ),
                          );
                        }
                        return ListingCard(
                          listing: _items[i],
                          onTap: () => context.push(
                            '/taladsod/listings/${_items[i].id}',
                          ),
                        );
                      },
                    ),
                  ),
          ),
          if (!_loading && _items.isEmpty && !_initialError)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 80, horizontal: 24),
              child: _Empty(),
            ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.sort,
    required this.organicOnly,
    required this.categoryId,
    required this.onSortChanged,
    required this.onOrganicToggled,
    required this.onClearCategory,
  });

  final String sort;
  final bool organicOnly;
  final int? categoryId;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<bool> onOrganicToggled;
  final VoidCallback onClearCategory;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (categoryId != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InputChip(
                label: const Text('หมวดหมู่'),
                onDeleted: onClearCategory,
                backgroundColor: TpColors.mintTint,
                deleteIconColor: TpColors.ink2,
              ),
            ),
          ChoiceChip(
            label: const Text('ใหม่ล่าสุด'),
            selected: sort == 'newest',
            onSelected: (_) => onSortChanged('newest'),
          ),
          const SizedBox(width: 6),
          ChoiceChip(
            label: const Text('ราคาต่ำ'),
            selected: sort == 'price_asc',
            onSelected: (_) => onSortChanged('price_asc'),
          ),
          const SizedBox(width: 6),
          ChoiceChip(
            label: const Text('ราคาสูง'),
            selected: sort == 'price_desc',
            onSelected: (_) => onSortChanged('price_desc'),
          ),
          const SizedBox(width: 6),
          ChoiceChip(
            label: const Text('ขายดี'),
            selected: sort == 'popular',
            onSelected: (_) => onSortChanged('popular'),
          ),
          const SizedBox(width: 12),
          FilterChip(
            label: const Text('🌱 ออร์แกนิก'),
            selected: organicOnly,
            onSelected: onOrganicToggled,
            backgroundColor: TpColors.card,
            selectedColor: const Color(0xFFE5F6CC),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.search_off,
            size: 48, color: TpColors.muted),
        const SizedBox(height: 12),
        Text('ไม่พบสินค้าตามเงื่อนไข',
            style: TpText.titleLg.copyWith(color: TpColors.muted)),
        const SizedBox(height: 4),
        Text('ลองลด filter หรือพิมพ์คำค้นใหม่',
            style: TpText.bodySm.copyWith(color: TpColors.muted)),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 48, color: TpColors.pink),
          const SizedBox(height: 12),
          Text('โหลดสินค้าไม่ได้',
              style: TpText.titleLg.copyWith(color: TpColors.ink)),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              message.length > 120
                  ? '${message.substring(0, 120)}...'
                  : message,
              textAlign: TextAlign.center,
              style: TpText.bodySm.copyWith(color: TpColors.muted),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('ลองใหม่')),
        ],
      ),
    );
  }
}
