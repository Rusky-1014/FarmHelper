class MedicineInfo {
  final String name;
  final String dosage;
  final String frequency;
  final String notes;

  const MedicineInfo({
    required this.name,
    required this.dosage,
    required this.frequency,
    this.notes = "",
  });
}

class MedicineService {
  static const Map<String, MedicineInfo> _mangoCures = {
    "Anthracnose": MedicineInfo(
      name: "Copper Oxychloride 50% WP",
      dosage: "3 g/L water",
      frequency: "Every 10 days (3 sprays)",
      notes: "Spray before monsoon; avoid spraying in rain.",
    ),
    "Bacterial Canker": MedicineInfo(
      name: "Streptomycin Sulfate + Copper Hydroxide",
      dosage: "0.5 g/L + 2 g/L water",
      frequency: "Every 15 days",
      notes: "Prune infected branches and seal cuts with Bordeaux paste.",
    ),
    "Cutting Weevil": MedicineInfo(
      name: "Chlorpyrifos 20 EC",
      dosage: "2 mL/L water",
      frequency: "At bud burst stage",
      notes: "Also remove and destroy fallen leaves and shoot tips.",
    ),
    "Die Back": MedicineInfo(
      name: "Carbendazim 50% WP",
      dosage: "1 g/L water",
      frequency: "Every 15 days (2–3 sprays)",
      notes: "Prune 10 cm below visible infection; burn pruned material.",
    ),
    "Gall Midge": MedicineInfo(
      name: "Dimethoate 30 EC",
      dosage: "1.5 mL/L water",
      frequency: "2 sprays at 15-day intervals at bud stage",
      notes: "Destroy fallen infested flowers and shoots.",
    ),
    "Healthy": MedicineInfo(
      name: "None required",
      dosage: "–",
      frequency: "–",
      notes: "Maintain regular irrigation and balanced fertilization.",
    ),
    "Powdery Mildew": MedicineInfo(
      name: "Wettable Sulfur 80% WP",
      dosage: "2 g/L water",
      frequency: "Every 10–12 days (3 sprays)",
      notes: "Do not spray in high temperatures (>35°C).",
    ),
    "Sooty Mould": MedicineInfo(
      name: "Starch solution + Neem oil",
      dosage: "Starch 2% + Neem 5 mL/L water",
      frequency: "Weekly until mould clears",
      notes:
          "Control the underlying scale/mealybug infestation with Imidacloprid 0.5 mL/L.",
    ),
  };

  static const Map<String, MedicineInfo> _grapeCures = {
    "Black Rot": MedicineInfo(
      name: "Mancozeb 75% WP",
      dosage: "2.5 g/L water",
      frequency: "Every 7–10 days pre-bloom",
      notes: "Remove and destroy all mummified berries.",
    ),
    "ESCA": MedicineInfo(
      name: "No chemical cure; use Trichoderma spp. (bio-agent)",
      dosage: "5 g/L water (drenching)",
      frequency: "At pruning, once per season",
      notes:
          "Seal pruning wounds with Thiram paste. Remove severely infected vines.",
    ),
    "Healthy": MedicineInfo(
      name: "None required",
      dosage: "–",
      frequency: "–",
      notes: "Continue good canopy management and balanced nutrition.",
    ),
    "Leaf Blight": MedicineInfo(
      name: "Azoxystrobin 23 SC",
      dosage: "1 mL/L water",
      frequency: "Every 14 days (3 sprays)",
      notes: "Alternate with Copper-based fungicides to prevent resistance.",
    ),
  };

  static MedicineInfo getMedicine(String crop, String disease) {
    if (crop == "mango") {
      return _mangoCures[disease] ??
          const MedicineInfo(
            name: "Consult local agronomist",
            dosage: "As advised",
            frequency: "As advised",
          );
    } else {
      return _grapeCures[disease] ??
          const MedicineInfo(
            name: "Consult local agronomist",
            dosage: "As advised",
            frequency: "As advised",
          );
    }
  }
}