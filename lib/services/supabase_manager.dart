import 'package:cadence_mtb/models/content_models.dart';
import 'package:cadence_mtb/utilities/keys.dart';
import 'package:supabase/supabase.dart';

class SupabaseManager {
  static final SupabaseClient client = SupabaseClient(
      'https://pviwskgeiigkpxwzzytr.supabase.co', Constants.supabaseKey);

  static Future<List<TrailsItem>> getTrailsList() async {
    final response = await client
        .from('trails_content_tbl')
        .select()
        .order('trailName', ascending: true)
        .onError(
            (error, stackTrace) => Future.error('Failed to fetch new trails'));

    final dataList = response;
    //It actually returns a list of map rather than list of json string.
    return dataList.map((e) => TrailsItem.fromMap(e)).toList();
  }

  static Future<List<OrganizationsItem>> getOrganizationsList() async {
    final response = await client
        .from('organizations_content_tbl')
        .select()
        .order('name', ascending: true)
        .onError((error, stackTrace) =>
            Future.error('Failed to fetch organizations'));

    final dataList = response;
    //It actually returns a list of map rather than list of json string.
    return dataList.map((e) => OrganizationsItem.fromMap(e)).toList();
  }
}
