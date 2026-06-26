/*
* Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
*
* Licensed under the Apache License, Version 2.0 (the "License").
* You may not use this file except in compliance with the License.
* A copy of the License is located at
*
*  http://aws.amazon.com/apache2.0
*
* or in the "license" file accompanying this file. This file is distributed
* on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
* express or implied. See the License for the specific language governing
* permissions and limitations under the License.
*/

// NOTE: This file is generated and may not follow lint rules defined in your app
// Generated files can be excluded from analysis in analysis_options.yaml
// For more info, see: https://dart.dev/guides/language/analysis-options#excluding-code-from-analysis

// ignore_for_file: public_member_api_docs, annotate_overrides, dead_code, dead_codepublic_member_api_docs, depend_on_referenced_packages, file_names, library_private_types_in_public_api, no_leading_underscores_for_library_prefixes, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, null_check_on_nullable_type_parameter, override_on_non_overriding_member, prefer_adjacent_string_concatenation, prefer_const_constructors, prefer_if_null_operators, prefer_interpolation_to_compose_strings, slash_for_doc_comments, sort_child_properties_last, unnecessary_const, unnecessary_constructor_name, unnecessary_late, unnecessary_new, unnecessary_null_aware_assignments, unnecessary_nullable_for_final_variable_declarations, unnecessary_string_interpolations, use_build_context_synchronously

import 'package:amplify_core/amplify_core.dart' as amplify_core;
import 'ActivityLogs.dart';
import 'Billings.dart';
import 'Checklists.dart';
import 'ClientDocuments.dart';
import 'ClientLicenses.dart';
import 'Clients.dart';
import 'CompanyBills.dart';
import 'DealActivities.dart';
import 'DealAssignees.dart';
import 'DealHandoverHistory.dart';
import 'DealStageHistory.dart';
import 'Deals.dart';
import 'DscRecords.dart';
import 'InwardPosts.dart';
import 'LicenseBilling.dart';
import 'LicenseNotifications.dart';
import 'LicenseServices.dart';
import 'LicenseTypes.dart';
import 'LocationHistory.dart';
import 'Messages.dart';
import 'Notifications.dart';
import 'ServiceContent.dart';
import 'ServiceNames.dart';
import 'StaffAttendance.dart';
import 'StaffLocations.dart';
import 'SysCronLogs.dart';
import 'Tasks.dart';
import 'TravelLogs.dart';
import 'UserSessions.dart';
import 'Users.dart';
import 'Properties.dart';
export 'ActivityLogs.dart';
export 'Billings.dart';
export 'Checklists.dart';
export 'ClientDocuments.dart';
export 'ClientLicenses.dart';
export 'Clients.dart';
export 'CompanyBills.dart';
export 'DealActivities.dart';
export 'DealAssignees.dart';
export 'DealHandoverHistory.dart';
export 'DealStageHistory.dart';
export 'Deals.dart';
export 'DscRecords.dart';
export 'InwardPosts.dart';
export 'LicenseBilling.dart';
export 'LicenseNotifications.dart';
export 'LicenseServices.dart';
export 'LicenseTypes.dart';
export 'LocationHistory.dart';
export 'Messages.dart';
export 'Notifications.dart';
export 'ServiceContent.dart';
export 'ServiceNames.dart';
export 'StaffAttendance.dart';
export 'StaffLocations.dart';
export 'SysCronLogs.dart';
export 'Tasks.dart';
export 'TravelLogs.dart';
export 'UserSessions.dart';
export 'Users.dart';
export 'Properties.dart';

class ModelProvider implements amplify_core.ModelProviderInterface {
  @override
  String version = "0f510e0c6ddf696dafddce15288cc15d";
  @override
  List<amplify_core.ModelSchema> modelSchemas = [
    ActivityLogs.schema,
    Billings.schema,
    Checklists.schema,
    ClientDocuments.schema,
    ClientLicenses.schema,
    Clients.schema,
    CompanyBills.schema,
    DealActivities.schema,
    DealAssignees.schema,
    DealHandoverHistory.schema,
    DealStageHistory.schema,
    Deals.schema,
    DscRecords.schema,
    InwardPosts.schema,
    LicenseBilling.schema,
    LicenseNotifications.schema,
    LicenseServices.schema,
    LicenseTypes.schema,
    LocationHistory.schema,
    Messages.schema,
    Notifications.schema,
    ServiceContent.schema,
    ServiceNames.schema,
    StaffAttendance.schema,
    StaffLocations.schema,
    SysCronLogs.schema,
    Tasks.schema,
    TravelLogs.schema,
    UserSessions.schema,
    Users.schema,
    Properties.schema,
  ];
  @override
  List<amplify_core.ModelSchema> customTypeSchemas = [];
  static final ModelProvider _instance = ModelProvider();

  static ModelProvider get instance => _instance;

  amplify_core.ModelType getModelTypeByModelName(String modelName) {
    switch (modelName) {
      case "ActivityLogs":
        return ActivityLogs.classType;
      case "Billings":
        return Billings.classType;
      case "Checklists":
        return Checklists.classType;
      case "ClientDocuments":
        return ClientDocuments.classType;
      case "ClientLicenses":
        return ClientLicenses.classType;
      case "Clients":
        return Clients.classType;
      case "CompanyBills":
        return CompanyBills.classType;
      case "DealActivities":
        return DealActivities.classType;
      case "DealAssignees":
        return DealAssignees.classType;
      case "DealHandoverHistory":
        return DealHandoverHistory.classType;
      case "DealStageHistory":
        return DealStageHistory.classType;
      case "Deals":
        return Deals.classType;
      case "DscRecords":
        return DscRecords.classType;
      case "InwardPosts":
        return InwardPosts.classType;
      case "LicenseBilling":
        return LicenseBilling.classType;
      case "LicenseNotifications":
        return LicenseNotifications.classType;
      case "LicenseServices":
        return LicenseServices.classType;
      case "LicenseTypes":
        return LicenseTypes.classType;
      case "LocationHistory":
        return LocationHistory.classType;
      case "Messages":
        return Messages.classType;
      case "Notifications":
        return Notifications.classType;
      case "Properties":
        return Properties.classType;
      case "ServiceContent":
        return ServiceContent.classType;
      case "ServiceNames":
        return ServiceNames.classType;
      case "StaffAttendance":
        return StaffAttendance.classType;
      case "StaffLocations":
        return StaffLocations.classType;
      case "SysCronLogs":
        return SysCronLogs.classType;
      case "Tasks":
        return Tasks.classType;
      case "TravelLogs":
        return TravelLogs.classType;
      case "UserSessions":
        return UserSessions.classType;
      case "Users":
        return Users.classType;
      default:
        throw Exception(
          "Failed to find model in model provider for model name: " + modelName,
        );
    }
  }
}

class ModelFieldValue<T> {
  const ModelFieldValue.value(this.value);

  final T value;
}
