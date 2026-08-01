import 'package:content_builder/src/model/content_row.dart';
import 'package:content_builder/src/model/geography.dart';
import 'package:content_builder/src/model/identification.dart';
import 'package:content_builder/src/model/plate_spec.dart';
import 'package:content_builder/src/model/regulation.dart';
import 'package:content_builder/src/model/taxon.dart';
import 'package:content_builder/src/model/text.dart';

/// Every authoring section, and the typed row it becomes.
///
/// The map is the seam between the authoring format and `SPEC.md` §7.1. A
/// section with no builder here is a section the emitter silently drops — a
/// whole file's worth of rules that validate, pass every assertion and are
/// simply not in the database — so a test asserts this map covers exactly the
/// sections `authoring_format.dart` declares.
///
/// `content_meta` has no entry: its three rows are written by the build from the
/// CLI's own `--build-date` and `--generator-commit`, and authoring them would
/// let the file disagree with the run that produced it.
const Map<String, RowBuilder> kRowBuilders = <String, RowBuilder>{
  'jurisdiction': JurisdictionRow.fromRow,
  'zones': ZoneRow.fromRow,
  'zone_rings': ZoneRingRow.fromRow,
  'families': FamilyRow.fromRow,
  'species': SpeciesRow.fromRow,
  'species_names': SpeciesNameRow.fromRow,
  'lookalikes': LookalikeRow.fromRow,
  'plates': PlateSpec.fromRow,
  'measurement_methods': MeasurementMethodRow.fromRow,
  'citations': CitationRow.fromRow,
  'rules': RuleRow.fromRow,
  'closed_seasons': ClosedSeasonRow.fromRow,
  'licence_types': LicenceTypeRow.fromRow,
  'gear_rules': GearRuleRow.fromRow,
  'penalties': PenaltyRow.fromRow,
  'legal_texts': LegalTextRow.fromRow,
  'strings': ContentStringRow.fromRow,
  'glossary_terms': GlossaryTermRow.fromRow,
  'changes': ContentChangeRow.fromRow,
  'key_nodes': KeyNodeRow.fromRow,
  'key_options': KeyOptionRow.fromRow,
  'key_leaf_species': KeyLeafSpeciesRow.fromRow,
};
