import 'package:flutter/material.dart';

// ---- Theme ----
const Color _kBg = Color(0xFF0D0D0D);
const Color _kSurface = Color(0xFF1A1717);
const Color _kCardBg = Color(0xFF1C1919);
const Color _kGold = Color(0xFFCBA35C);
const Color _kGoldLight = Color(0xFFE4C98A);
const Color _kMaroon = Color(0xFF7A1F35);
const Color _kMuted = Color(0xFF9B9B9B);
const Color _kBorder = Color(0xFF2A2626);

// ---- Worldwide Student Locations ----
const List<Map<String, String>> _kWorldLocations = [
  // Pakistan
  {'city': 'Lahore',      'area': 'DHA / Johar Town',         'country': 'Pakistan',    'flag': '🇵🇰'},
  {'city': 'Islamabad',   'area': 'F-7 / F-8 / Blue Area',    'country': 'Pakistan',    'flag': '🇵🇰'},
  {'city': 'Karachi',     'area': 'DHA / Gulshan / Clifton',  'country': 'Pakistan',    'flag': '🇵🇰'},
  {'city': 'Peshawar',    'area': 'Hayatabad / University Rd','country': 'Pakistan',    'flag': '🇵🇰'},
  {'city': 'Faisalabad',  'area': 'Peoples Colony / NFC',     'country': 'Pakistan',    'flag': '🇵🇰'},
  {'city': 'Rawalpindi',  'area': 'Saddar / Bahria Town',     'country': 'Pakistan',    'flag': '🇵🇰'},
  {'city': 'Multan',      'area': 'Gulgasht / Cantt',         'country': 'Pakistan',    'flag': '🇵🇰'},
  {'city': 'Quetta',      'area': 'Satellite Town / Jinnah Rd','country': 'Pakistan',   'flag': '🇵🇰'},
  // UK
  {'city': 'London',      'area': 'Stratford / Mile End / Bethnal Green','country': 'UK','flag': '🇬🇧'},
  {'city': 'Manchester',  'area': 'Fallowfield / Withington / Rusholme','country': 'UK', 'flag': '🇬🇧'},
  {'city': 'Birmingham',  'area': 'Selly Oak / Edgbaston',    'country': 'UK',          'flag': '🇬🇧'},
  {'city': 'Leeds',       'area': 'Hyde Park / Headingley',   'country': 'UK',          'flag': '🇬🇧'},
  {'city': 'Edinburgh',   'area': 'Marchmont / Newington',    'country': 'UK',          'flag': '🇬🇧'},
  {'city': 'Sheffield',   'area': 'Crookes / Broomhill',      'country': 'UK',          'flag': '🇬🇧'},
  {'city': 'Nottingham',  'area': 'Lenton / Beeston',         'country': 'UK',          'flag': '🇬🇧'},
  // USA
  {'city': 'New York',    'area': 'Manhattan / Brooklyn / Queens','country': 'USA',      'flag': '🇺🇸'},
  {'city': 'Los Angeles', 'area': 'Westwood / Koreatown / Culver City','country': 'USA', 'flag': '🇺🇸'},
  {'city': 'Chicago',     'area': 'Hyde Park / Lincoln Park',  'country': 'USA',         'flag': '🇺🇸'},
  {'city': 'Houston',     'area': 'University District / Midtown','country': 'USA',      'flag': '🇺🇸'},
  {'city': 'Boston',      'area': 'Allston / Brighton / Fenway','country': 'USA',        'flag': '🇺🇸'},
  {'city': 'San Francisco','area': 'Mission / SOMA / Castro',  'country': 'USA',         'flag': '🇺🇸'},
  // Canada
  {'city': 'Toronto',     'area': 'Annex / Kensington / Scarborough','country': 'Canada','flag': '🇨🇦'},
  {'city': 'Vancouver',   'area': 'UBC / Kitsilano / East Van','country': 'Canada',      'flag': '🇨🇦'},
  {'city': 'Montreal',    'area': 'Plateau / McGill Ghetto',   'country': 'Canada',      'flag': '🇨🇦'},
  {'city': 'Calgary',     'area': 'Brentwood / Varsity',       'country': 'Canada',      'flag': '🇨🇦'},
  // Australia
  {'city': 'Melbourne',   'area': 'Carlton / Fitzroy / Brunswick','country': 'Australia','flag': '🇦🇺'},
  {'city': 'Sydney',      'area': 'Ultimo / Newtown / Redfern','country': 'Australia',   'flag': '🇦🇺'},
  {'city': 'Brisbane',    'area': 'West End / St Lucia',       'country': 'Australia',   'flag': '🇦🇺'},
  {'city': 'Adelaide',    'area': 'Kensington / Goodwood',     'country': 'Australia',   'flag': '🇦🇺'},
  // Middle East
  {'city': 'Dubai',       'area': 'Al Barsha / Deira / JLT',  'country': 'UAE',         'flag': '🇦🇪'},
  {'city': 'Abu Dhabi',   'area': 'Khalidiyah / Electra St',  'country': 'UAE',         'flag': '🇦🇪'},
  {'city': 'Riyadh',      'area': 'Al Malqa / Olaya / Sulaimaniyah','country': 'Saudi Arabia','flag': '🇸🇦'},
  {'city': 'Doha',        'area': 'Education City / Al Sadd',  'country': 'Qatar',       'flag': '🇶🇦'},
  // Europe
  {'city': 'Berlin',      'area': 'Mitte / Prenzlauer Berg / Neukölln','country': 'Germany','flag': '🇩🇪'},
  {'city': 'Munich',      'area': 'Schwabing / Maxvorstadt',   'country': 'Germany',     'flag': '🇩🇪'},
  {'city': 'Paris',       'area': 'Latin Quarter / Montmartre','country': 'France',      'flag': '🇫🇷'},
  {'city': 'Amsterdam',   'area': 'De Pijp / Jordaan / Oud-West','country': 'Netherlands','flag': '🇳🇱'},
  {'city': 'Barcelona',   'area': 'Gracia / Poblenou / El Clot','country': 'Spain',      'flag': '🇪🇸'},
  {'city': 'Madrid',      'area': 'Malasaña / Lavapiés',       'country': 'Spain',       'flag': '🇪🇸'},
  {'city': 'Dublin',      'area': 'Rathmines / Ranelagh',      'country': 'Ireland',     'flag': '🇮🇪'},
];

class FilterCriteria {
  final String location;
  final String budget;
  final String religion;

  const FilterCriteria({
    this.location = '',
    this.budget = '',
    this.religion = '',
  });
}

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _religionController = TextEditingController();
  final TextEditingController _locationSearchController =
      TextEditingController();

  String? _selectedCity;
  String _locationSearch = '';
  bool _showLocationPicker = false;

  @override
  void dispose() {
    _locationController.dispose();
    _budgetController.dispose();
    _religionController.dispose();
    _locationSearchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    Navigator.of(context).pop(
      FilterCriteria(
        location: _selectedCity ?? _locationController.text.trim(),
        budget: _budgetController.text.trim(),
        religion: _religionController.text.trim(),
      ),
    );
  }

  void _clearFilters() {
    _locationController.clear();
    _budgetController.clear();
    _religionController.clear();
    _locationSearchController.clear();
    setState(() {
      _selectedCity = null;
      _locationSearch = '';
      _showLocationPicker = false;
    });
  }

  List<Map<String, String>> get _filteredLocations {
    if (_locationSearch.isEmpty) return _kWorldLocations;
    final q = _locationSearch.toLowerCase();
    return _kWorldLocations.where((loc) {
      return loc['city']!.toLowerCase().contains(q) ||
          loc['country']!.toLowerCase().contains(q) ||
          loc['area']!.toLowerCase().contains(q);
    }).toList();
  }

  // Group locations by country for display
  Map<String, List<Map<String, String>>> get _groupedLocations {
    final Map<String, List<Map<String, String>>> grouped = {};
    for (final loc in _filteredLocations) {
      final country = loc['country']!;
      grouped.putIfAbsent(country, () => []).add(loc);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Filter Listings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _clearFilters,
            child: const Text(
              'Clear All',
              style: TextStyle(color: _kGold, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Location Section ──
                _buildSectionLabel(Icons.public, 'Location'),
                const SizedBox(height: 10),
                _buildLocationButton(),
                if (_showLocationPicker) _buildLocationPicker(),
                const SizedBox(height: 20),

                // ── Budget Section ──
                _buildSectionLabel(Icons.payments_outlined, 'Budget (max)'),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _budgetController,
                  hint: 'e.g. 20000 or 800 (any currency)',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),

                // ── Preference Section ──
                _buildSectionLabel(Icons.person_outline, 'Preference / Religion'),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _religionController,
                  hint: 'e.g. Muslim, Christian, Any',
                  icon: Icons.diversity_1_outlined,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),

          // ── Apply Button ──
          Container(
            decoration: const BoxDecoration(
              color: _kSurface,
              border: Border(top: BorderSide(color: _kBorder)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kMaroon,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: _kGold, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _kMuted, fontSize: 13),
          prefixIcon: Icon(icon, color: _kGold, size: 18),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildLocationButton() {
    final hasSelection = _selectedCity != null && _selectedCity!.isNotEmpty;
    return GestureDetector(
      onTap: () => setState(() => _showLocationPicker = !_showLocationPicker),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasSelection ? _kGold : _kBorder,
            width: hasSelection ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on_outlined, color: _kGold, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hasSelection ? _selectedCity! : 'Select a city or type location...',
                style: TextStyle(
                  color: hasSelection ? Colors.white : _kMuted,
                  fontSize: 14,
                ),
              ),
            ),
            if (hasSelection)
              GestureDetector(
                onTap: () => setState(() => _selectedCity = null),
                child: const Icon(Icons.close, color: _kMuted, size: 16),
              ),
            const SizedBox(width: 8),
            AnimatedRotation(
              turns: _showLocationPicker ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.keyboard_arrow_down, color: _kGold, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationPicker() {
    final grouped = _groupedLocations;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar inside picker
          Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kBorder),
            ),
            child: TextField(
              controller: _locationSearchController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              autofocus: false,
              onChanged: (v) => setState(() => _locationSearch = v.trim()),
              decoration: const InputDecoration(
                hintText: 'Search city, country or area...',
                hintStyle: TextStyle(color: _kMuted, fontSize: 12.5),
                prefixIcon: Icon(Icons.search, color: _kGold, size: 18),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              ),
            ),
          ),

          // Grouped country list
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 340),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: grouped.entries.map((entry) {
                final country = entry.key;
                final locations = entry.value;
                final flag = locations.first['flag']!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Country header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                      child: Row(
                        children: [
                          Text(flag, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            country,
                            style: const TextStyle(
                              color: _kGoldLight,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // City rows
                    ...locations.map((loc) {
                      final isSelected = _selectedCity == loc['city'];
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCity = loc['city'];
                            _showLocationPicker = false;
                            _locationSearch = '';
                            _locationSearchController.clear();
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(28, 10, 14, 10),
                          color: isSelected
                              ? _kGold.withValues(alpha: 0.1)
                              : Colors.transparent,
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.location_city_outlined,
                                color: isSelected ? _kGold : _kMuted,
                                size: 16,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      loc['city']!,
                                      style: TextStyle(
                                        color: isSelected
                                            ? _kGoldLight
                                            : Colors.white,
                                        fontSize: 13.5,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    Text(
                                      loc['area']!,
                                      style: const TextStyle(
                                        color: _kMuted,
                                        fontSize: 10.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    Divider(
                      height: 1,
                      color: _kBorder.withValues(alpha: 0.5),
                      indent: 14,
                      endIndent: 14,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
