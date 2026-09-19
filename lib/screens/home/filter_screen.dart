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
  {'city': 'Lahore',      'area': 'DHA / Johar Town',         'country': 'Pakistan',    'flag': 'ðŸ‡µðŸ‡°'},
  {'city': 'Islamabad',   'area': 'F-7 / F-8 / Blue Area',    'country': 'Pakistan',    'flag': 'ðŸ‡µðŸ‡°'},
  {'city': 'Karachi',     'area': 'DHA / Gulshan / Clifton',  'country': 'Pakistan',    'flag': 'ðŸ‡µðŸ‡°'},
  {'city': 'Peshawar',    'area': 'Hayatabad / University Rd','country': 'Pakistan',    'flag': 'ðŸ‡µðŸ‡°'},
  {'city': 'Faisalabad',  'area': 'Peoples Colony / NFC',     'country': 'Pakistan',    'flag': 'ðŸ‡µðŸ‡°'},
  {'city': 'Rawalpindi',  'area': 'Saddar / Bahria Town',     'country': 'Pakistan',    'flag': 'ðŸ‡µðŸ‡°'},
  {'city': 'Multan',      'area': 'Gulgasht / Cantt',         'country': 'Pakistan',    'flag': 'ðŸ‡µðŸ‡°'},
  {'city': 'Quetta',      'area': 'Satellite Town / Jinnah Rd','country': 'Pakistan',   'flag': 'ðŸ‡µðŸ‡°'},
  // UK
  {'city': 'London',      'area': 'Stratford / Mile End / Bethnal Green','country': 'UK','flag': 'ðŸ‡¬ðŸ‡§'},
  {'city': 'Manchester',  'area': 'Fallowfield / Withington / Rusholme','country': 'UK', 'flag': 'ðŸ‡¬ðŸ‡§'},
  {'city': 'Birmingham',  'area': 'Selly Oak / Edgbaston',    'country': 'UK',          'flag': 'ðŸ‡¬ðŸ‡§'},
  {'city': 'Leeds',       'area': 'Hyde Park / Headingley',   'country': 'UK',          'flag': 'ðŸ‡¬ðŸ‡§'},
  {'city': 'Edinburgh',   'area': 'Marchmont / Newington',    'country': 'UK',          'flag': 'ðŸ‡¬ðŸ‡§'},
  {'city': 'Sheffield',   'area': 'Crookes / Broomhill',      'country': 'UK',          'flag': 'ðŸ‡¬ðŸ‡§'},
  {'city': 'Nottingham',  'area': 'Lenton / Beeston',         'country': 'UK',          'flag': 'ðŸ‡¬ðŸ‡§'},
  // USA
  {'city': 'New York',    'area': 'Manhattan / Brooklyn / Queens','country': 'USA',      'flag': 'ðŸ‡ºðŸ‡¸'},
  {'city': 'Los Angeles', 'area': 'Westwood / Koreatown / Culver City','country': 'USA', 'flag': 'ðŸ‡ºðŸ‡¸'},
  {'city': 'Chicago',     'area': 'Hyde Park / Lincoln Park',  'country': 'USA',         'flag': 'ðŸ‡ºðŸ‡¸'},
  {'city': 'Houston',     'area': 'University District / Midtown','country': 'USA',      'flag': 'ðŸ‡ºðŸ‡¸'},
  {'city': 'Boston',      'area': 'Allston / Brighton / Fenway','country': 'USA',        'flag': 'ðŸ‡ºðŸ‡¸'},
  {'city': 'San Francisco','area': 'Mission / SOMA / Castro',  'country': 'USA',         'flag': 'ðŸ‡ºðŸ‡¸'},
  // Canada
  {'city': 'Toronto',     'area': 'Annex / Kensington / Scarborough','country': 'Canada','flag': 'ðŸ‡¨ðŸ‡¦'},
  {'city': 'Vancouver',   'area': 'UBC / Kitsilano / East Van','country': 'Canada',      'flag': 'ðŸ‡¨ðŸ‡¦'},
  {'city': 'Montreal',    'area': 'Plateau / McGill Ghetto',   'country': 'Canada',      'flag': 'ðŸ‡¨ðŸ‡¦'},
  {'city': 'Calgary',     'area': 'Brentwood / Varsity',       'country': 'Canada',      'flag': 'ðŸ‡¨ðŸ‡¦'},
  // Australia
  {'city': 'Melbourne',   'area': 'Carlton / Fitzroy / Brunswick','country': 'Australia','flag': 'ðŸ‡¦ðŸ‡º'},
  {'city': 'Sydney',      'area': 'Ultimo / Newtown / Redfern','country': 'Australia',   'flag': 'ðŸ‡¦ðŸ‡º'},
  {'city': 'Brisbane',    'area': 'West End / St Lucia',       'country': 'Australia',   'flag': 'ðŸ‡¦ðŸ‡º'},
  {'city': 'Adelaide',    'area': 'Kensington / Goodwood',     'country': 'Australia',   'flag': 'ðŸ‡¦ðŸ‡º'},
  // Middle East
  {'city': 'Dubai',       'area': 'Al Barsha / Deira / JLT',  'country': 'UAE',         'flag': 'ðŸ‡¦ðŸ‡ª'},
  {'city': 'Abu Dhabi',   'area': 'Khalidiyah / Electra St',  'country': 'UAE',         'flag': 'ðŸ‡¦ðŸ‡ª'},
  {'city': 'Riyadh',      'area': 'Al Malqa / Olaya / Sulaimaniyah','country': 'Saudi Arabia','flag': 'ðŸ‡¸ðŸ‡¦'},
  {'city': 'Doha',        'area': 'Education City / Al Sadd',  'country': 'Qatar',       'flag': 'ðŸ‡¶ðŸ‡¦'},
  // Europe
  {'city': 'Berlin',      'area': 'Mitte / Prenzlauer Berg / NeukÃ¶lln','country': 'Germany','flag': 'ðŸ‡©ðŸ‡ª'},
  {'city': 'Munich',      'area': 'Schwabing / Maxvorstadt',   'country': 'Germany',     'flag': 'ðŸ‡©ðŸ‡ª'},
  {'city': 'Paris',       'area': 'Latin Quarter / Montmartre','country': 'France',      'flag': 'ðŸ‡«ðŸ‡·'},
  {'city': 'Amsterdam',   'area': 'De Pijp / Jordaan / Oud-West','country': 'Netherlands','flag': 'ðŸ‡³ðŸ‡±'},
  {'city': 'Barcelona',   'area': 'Gracia / Poblenou / El Clot','country': 'Spain',      'flag': 'ðŸ‡ªðŸ‡¸'},
  {'city': 'Madrid',      'area': 'MalasaÃ±a / LavapiÃ©s',       'country': 'Spain',       'flag': 'ðŸ‡ªðŸ‡¸'},
  {'city': 'Dublin',      'area': 'Rathmines / Ranelagh',      'country': 'Ireland',     'flag': 'ðŸ‡®ðŸ‡ª'},
];

class FilterCriteria {
  final String location;
  final String budget;
  final String religion;
  final double radiusKm; // 0 = no radius filter

  const FilterCriteria({
    this.location = '',
    this.budget = '',
    this.religion = '',
    this.radiusKm = 0,
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
  double _radiusKm = 0; // 0 = off

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
        radiusKm: _radiusKm,
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
      _radiusKm = 0;
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
                // â”€â”€ Location Section â”€â”€
                _buildSectionLabel(Icons.public, 'Location'),
                const SizedBox(height: 10),
                _buildLocationButton(),
                if (_showLocationPicker) _buildLocationPicker(),
                const SizedBox(height: 20),

                // â”€â”€ Nearby Radius Section â”€â”€
                _buildSectionLabel(Icons.radar, 'Nearby Radius'),
                const SizedBox(height: 8),
                _buildRadiusSlider(),
                const SizedBox(height: 20),

                // â”€â”€ Budget Section â”€â”€
                _buildSectionLabel(Icons.payments_outlined, 'Budget (max)'),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _budgetController,
                  hint: 'e.g. 20000 or 800 (any currency)',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),

                // â”€â”€ Preference Section â”€â”€
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

          // â”€â”€ Apply Button â”€â”€
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

  Widget _buildRadiusSlider() {
    final isOff = _radiusKm <= 0;
    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOff ? _kBorder : _kGold.withValues(alpha: 0.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.my_location, color: isOff ? _kMuted : _kGold, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    isOff ? 'No radius limit' : '${_radiusKm.toInt()} km aas paas',
                    style: TextStyle(
                      color: isOff ? _kMuted : Colors.white,
                      fontSize: 13.5,
                      fontWeight: isOff ? FontWeight.normal : FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (!isOff)
                GestureDetector(
                  onTap: () => setState(() => _radiusKm = 0),
                  child: const Icon(Icons.close, color: _kMuted, size: 16),
                ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _kGold,
              inactiveTrackColor: _kBorder,
              thumbColor: _kGold,
              overlayColor: _kGold.withValues(alpha: 0.15),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              min: 0,
              max: 100,
              divisions: 20,
              value: _radiusKm,
              onChanged: (v) => setState(() => _radiusKm = v),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Off', style: TextStyle(color: _kMuted, fontSize: 10)),
              Text('100 km', style: TextStyle(color: _kMuted, fontSize: 10)),
            ],
          ),
        ],
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

