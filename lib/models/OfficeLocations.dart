import 'ModelProvider.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;

class OfficeLocations extends amplify_core.Model {
  static const classType = const _OfficeLocationsModelType();
  final String id;
  final String? _name;
  final String? _place;
  final String? _location_link;
  final String? _office_phone_numbers;
  final String? _front_view_photo;
  final String? _designation_boards_photos;
  final String? _notice_boards_photos;
  final String? _officers_contacts;
  final String? _other_photos;
  final String? _created_at;
  final String? _updated_at;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;
  
  @Deprecated('[getId] is being deprecated in favor of custom primary key feature. Use getter [modelIdentifier] to get model identifier.')
  @override
  String getId() => id;
  
  OfficeLocationsModelIdentifier get modelIdentifier {
      return OfficeLocationsModelIdentifier(id: id);
  }
  
  String? get name => _name;
  String? get place => _place;
  String? get location_link => _location_link;
  String? get office_phone_numbers => _office_phone_numbers;
  String? get front_view_photo => _front_view_photo;
  String? get designation_boards_photos => _designation_boards_photos;
  String? get notice_boards_photos => _notice_boards_photos;
  String? get officers_contacts => _officers_contacts;
  String? get other_photos => _other_photos;
  String? get created_at => _created_at;
  String? get updated_at => _updated_at;
  amplify_core.TemporalDateTime? get createdAt => _createdAt;
  amplify_core.TemporalDateTime? get updatedAt => _updatedAt;

  const OfficeLocations._internal({required this.id, name, place, location_link, office_phone_numbers, front_view_photo, designation_boards_photos, notice_boards_photos, officers_contacts, other_photos, created_at, updated_at, createdAt, updatedAt}): _name = name, _place = place, _location_link = location_link, _office_phone_numbers = office_phone_numbers, _front_view_photo = front_view_photo, _designation_boards_photos = designation_boards_photos, _notice_boards_photos = notice_boards_photos, _officers_contacts = officers_contacts, _other_photos = other_photos, _created_at = created_at, _updated_at = updated_at, _createdAt = createdAt, _updatedAt = updatedAt;
  
  factory OfficeLocations({String? id, required String name, required String place, String? location_link, String? office_phone_numbers, String? front_view_photo, String? designation_boards_photos, String? notice_boards_photos, String? officers_contacts, String? other_photos, String? created_at, String? updated_at}) {
    return OfficeLocations._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      name: name,
      place: place,
      location_link: location_link,
      office_phone_numbers: office_phone_numbers,
      front_view_photo: front_view_photo,
      designation_boards_photos: designation_boards_photos,
      notice_boards_photos: notice_boards_photos,
      officers_contacts: officers_contacts,
      other_photos: other_photos,
      created_at: created_at,
      updated_at: updated_at);
  }
  
  bool equals(Object other) {
    return this == other;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OfficeLocations &&
      id == other.id &&
      _name == other._name &&
      _place == other._place &&
      _location_link == other._location_link &&
      _office_phone_numbers == other._office_phone_numbers &&
      _front_view_photo == other._front_view_photo &&
      _designation_boards_photos == other._designation_boards_photos &&
      _notice_boards_photos == other._notice_boards_photos &&
      _officers_contacts == other._officers_contacts &&
      _other_photos == other._other_photos &&
      _created_at == other._created_at &&
      _updated_at == other._updated_at;
  }
  
  @override
  int get hashCode => toString().hashCode;
  
  @override
  String toString() {
    var buffer = new StringBuffer();
    
    buffer.write("OfficeLocations {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write("name=" + "$_name" + ", ");
    buffer.write("place=" + "$_place" + ", ");
    buffer.write("location_link=" + "$_location_link" + ", ");
    buffer.write("office_phone_numbers=" + "$_office_phone_numbers" + ", ");
    buffer.write("front_view_photo=" + "$_front_view_photo" + ", ");
    buffer.write("designation_boards_photos=" + "$_designation_boards_photos" + ", ");
    buffer.write("notice_boards_photos=" + "$_notice_boards_photos" + ", ");
    buffer.write("officers_contacts=" + "$_officers_contacts" + ", ");
    buffer.write("other_photos=" + "$_other_photos" + ", ");
    buffer.write("created_at=" + "$_created_at" + ", ");
    buffer.write("updated_at=" + "$_updated_at" + ", ");
    buffer.write("createdAt=" + (_createdAt != null ? _createdAt!.format() : "null") + ", ");
    buffer.write("updatedAt=" + (_updatedAt != null ? _updatedAt!.format() : "null"));
    buffer.write("}");
    
    return buffer.toString();
  }
  
  OfficeLocations copyWith({String? name, String? place, String? location_link, String? office_phone_numbers, String? front_view_photo, String? designation_boards_photos, String? notice_boards_photos, String? officers_contacts, String? other_photos, String? created_at, String? updated_at}) {
    return OfficeLocations._internal(
      id: id,
      name: name ?? this.name,
      place: place ?? this.place,
      location_link: location_link ?? this.location_link,
      office_phone_numbers: office_phone_numbers ?? this.office_phone_numbers,
      front_view_photo: front_view_photo ?? this.front_view_photo,
      designation_boards_photos: designation_boards_photos ?? this.designation_boards_photos,
      notice_boards_photos: notice_boards_photos ?? this.notice_boards_photos,
      officers_contacts: officers_contacts ?? this.officers_contacts,
      other_photos: other_photos ?? this.other_photos,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at);
  }
  
  OfficeLocations copyWithModelFieldValues({
    ModelFieldValue<String>? name,
    ModelFieldValue<String>? place,
    ModelFieldValue<String?>? location_link,
    ModelFieldValue<String?>? office_phone_numbers,
    ModelFieldValue<String?>? front_view_photo,
    ModelFieldValue<String?>? designation_boards_photos,
    ModelFieldValue<String?>? notice_boards_photos,
    ModelFieldValue<String?>? officers_contacts,
    ModelFieldValue<String?>? other_photos,
    ModelFieldValue<String?>? created_at,
    ModelFieldValue<String?>? updated_at
  }) {
    return OfficeLocations._internal(
      id: id,
      name: name == null ? this.name : name.value,
      place: place == null ? this.place : place.value,
      location_link: location_link == null ? this.location_link : location_link.value,
      office_phone_numbers: office_phone_numbers == null ? this.office_phone_numbers : office_phone_numbers.value,
      front_view_photo: front_view_photo == null ? this.front_view_photo : front_view_photo.value,
      designation_boards_photos: designation_boards_photos == null ? this.designation_boards_photos : designation_boards_photos.value,
      notice_boards_photos: notice_boards_photos == null ? this.notice_boards_photos : notice_boards_photos.value,
      officers_contacts: officers_contacts == null ? this.officers_contacts : officers_contacts.value,
      other_photos: other_photos == null ? this.other_photos : other_photos.value,
      created_at: created_at == null ? this.created_at : created_at.value,
      updated_at: updated_at == null ? this.updated_at : updated_at.value
    );
  }
  
  OfficeLocations.fromJson(Map<String, dynamic> json)  
    : id = json['id'],
      _name = json['name'],
      _place = json['place'],
      _location_link = json['location_link'],
      _office_phone_numbers = json['office_phone_numbers'],
      _front_view_photo = json['front_view_photo'],
      _designation_boards_photos = json['designation_boards_photos'],
      _notice_boards_photos = json['notice_boards_photos'],
      _officers_contacts = json['officers_contacts'],
      _other_photos = json['other_photos'],
      _created_at = json['created_at'],
      _updated_at = json['updated_at'],
      _createdAt = json['createdAt'] != null ? amplify_core.TemporalDateTime.fromString(json['createdAt']) : null,
      _updatedAt = json['updatedAt'] != null ? amplify_core.TemporalDateTime.fromString(json['updatedAt']) : null;
  
  Map<String, dynamic> toJson() => {
    'id': id, 'name': _name, 'place': _place, 'location_link': _location_link, 'office_phone_numbers': _office_phone_numbers, 'front_view_photo': _front_view_photo, 'designation_boards_photos': _designation_boards_photos, 'notice_boards_photos': _notice_boards_photos, 'officers_contacts': _officers_contacts, 'other_photos': _other_photos, 'created_at': _created_at, 'updated_at': _updated_at, 'createdAt': _createdAt?.format(), 'updatedAt': _updatedAt?.format()
  };
  
  Map<String, Object?> toMap() => {
    'id': id,
    'name': _name,
    'place': _place,
    'location_link': _location_link,
    'office_phone_numbers': _office_phone_numbers,
    'front_view_photo': _front_view_photo,
    'designation_boards_photos': _designation_boards_photos,
    'notice_boards_photos': _notice_boards_photos,
    'officers_contacts': _officers_contacts,
    'other_photos': _other_photos,
    'created_at': _created_at,
    'updated_at': _updated_at,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt
  };

  static final amplify_core.QueryModelIdentifier<OfficeLocationsModelIdentifier> MODEL_IDENTIFIER = amplify_core.QueryModelIdentifier<OfficeLocationsModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final NAME = amplify_core.QueryField(fieldName: "name");
  static final PLACE = amplify_core.QueryField(fieldName: "place");
  static final LOCATION_LINK = amplify_core.QueryField(fieldName: "location_link");
  static final OFFICE_PHONE_NUMBERS = amplify_core.QueryField(fieldName: "office_phone_numbers");
  static final FRONT_VIEW_PHOTO = amplify_core.QueryField(fieldName: "front_view_photo");
  static final DESIGNATION_BOARDS_PHOTOS = amplify_core.QueryField(fieldName: "designation_boards_photos");
  static final NOTICE_BOARDS_PHOTOS = amplify_core.QueryField(fieldName: "notice_boards_photos");
  static final OFFICERS_CONTACTS = amplify_core.QueryField(fieldName: "officers_contacts");
  static final OTHER_PHOTOS = amplify_core.QueryField(fieldName: "other_photos");
  static final CREATED_AT = amplify_core.QueryField(fieldName: "created_at");
  static final UPDATED_AT = amplify_core.QueryField(fieldName: "updated_at");
  static var schema = amplify_core.Model.defineSchema(define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
    modelSchemaDefinition.name = "OfficeLocations";
    modelSchemaDefinition.pluralName = "OfficeLocations";
    
    modelSchemaDefinition.authRules = [
      amplify_core.AuthRule(
        authStrategy: amplify_core.AuthStrategy.PRIVATE,
        operations: const [
          amplify_core.ModelOperation.CREATE,
          amplify_core.ModelOperation.UPDATE,
          amplify_core.ModelOperation.DELETE,
          amplify_core.ModelOperation.READ
        ])
    ];
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: OfficeLocations.NAME,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: OfficeLocations.PLACE,
      isRequired: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: OfficeLocations.LOCATION_LINK,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: OfficeLocations.OFFICE_PHONE_NUMBERS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: OfficeLocations.FRONT_VIEW_PHOTO,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: OfficeLocations.DESIGNATION_BOARDS_PHOTOS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: OfficeLocations.NOTICE_BOARDS_PHOTOS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: OfficeLocations.OFFICERS_CONTACTS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: OfficeLocations.OTHER_PHOTOS,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: OfficeLocations.CREATED_AT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.field(
      key: OfficeLocations.UPDATED_AT,
      isRequired: false,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.string)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'createdAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
    
    modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.nonQueryField(
      fieldName: 'updatedAt',
      isRequired: false,
      isReadOnly: true,
      ofType: amplify_core.ModelFieldType(amplify_core.ModelFieldTypeEnum.dateTime)
    ));
  });
}

class _OfficeLocationsModelType extends amplify_core.ModelType<OfficeLocations> {
  const _OfficeLocationsModelType();
  
  @override
  OfficeLocations fromJson(Map<String, dynamic> jsonData) {
    return OfficeLocations.fromJson(jsonData);
  }
  
  @override
  String modelName() {
    return 'OfficeLocations';
  }
}

class OfficeLocationsModelIdentifier implements amplify_core.ModelIdentifier<OfficeLocations> {
  final String id;

  const OfficeLocationsModelIdentifier({required this.id});
  
  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{
    'id': id
  });
  
  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap()
    .entries
    .map((entry) => (<String, dynamic>{ entry.key: entry.value }))
    .toList();
  
  @override
  String serializeAsString() => serializeAsMap().values.join('#');
  
  @override
  String toString() => 'OfficeLocationsModelIdentifier(id: $id)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    
    return other is OfficeLocationsModelIdentifier &&
      id == other.id;
  }
  
  @override
  int get hashCode =>
    id.hashCode;
}
