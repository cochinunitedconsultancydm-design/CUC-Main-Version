// NOTE: This file is generated and may not follow lint rules defined in your app
import 'ModelProvider.dart';
import 'package:collection/collection.dart';
import 'package:amplify_core/amplify_core.dart' as amplify_core;

class Properties extends amplify_core.Model {
  static const classType = const _PropertiesModelType();
  final String id;
  final String? _property_name;
  final String? _client_name;
  final String? _location;
  final String? _property_type;
  final String? _owner_name;
  final List<String>? _owner_phone_numbers;
  final String? _broker_details;
  final String? _care_of;
  final String? _transaction_type;
  final double? _advance_amount;
  final String? _period;
  final String? _area;
  final double? _price;
  final bool? _has_multiple_owners;
  final bool? _has_legal_disputes;
  final bool? _is_negotiable;
  final String? _floor;
  final bool? _has_balcony;
  final int? _balcony_count;
  final bool? _is_furnished;
  final bool? _has_car_parking;
  final String? _expenses;
  final List<String>? _photos;
  final String? _status;
  final String? _notes;
  final String? _created_at;
  final String? _updated_at;
  final amplify_core.TemporalDateTime? _createdAt;
  final amplify_core.TemporalDateTime? _updatedAt;

  @override
  getInstanceType() => classType;

  @override
  String getId() => id;

  PropertiesModelIdentifier get modelIdentifier {
    return PropertiesModelIdentifier(id: id);
  }

  String? get property_name => _property_name;
  String? get client_name => _client_name;
  String? get location => _location;
  String? get property_type => _property_type;
  String? get owner_name => _owner_name;
  List<String>? get owner_phone_numbers => _owner_phone_numbers;
  String? get broker_details => _broker_details;
  String? get care_of => _care_of;
  String? get transaction_type => _transaction_type;
  double? get advance_amount => _advance_amount;
  String? get period => _period;
  String? get area => _area;
  double? get price => _price;
  bool? get has_multiple_owners => _has_multiple_owners;
  bool? get has_legal_disputes => _has_legal_disputes;
  bool? get is_negotiable => _is_negotiable;
  String? get floor => _floor;
  bool? get has_balcony => _has_balcony;
  int? get balcony_count => _balcony_count;
  bool? get is_furnished => _is_furnished;
  bool? get has_car_parking => _has_car_parking;
  String? get expenses => _expenses;
  List<String>? get photos => _photos;
  String? get status => _status;
  String? get notes => _notes;
  String? get created_at => _created_at;
  String? get updated_at => _updated_at;
  amplify_core.TemporalDateTime? get createdAt => _createdAt;
  amplify_core.TemporalDateTime? get updatedAt => _updatedAt;

  const Properties._internal({
    required this.id,
    property_name,
    client_name,
    location,
    property_type,
    owner_name,
    owner_phone_numbers,
    broker_details,
    care_of,
    transaction_type,
    advance_amount,
    period,
    area,
    price,
    has_multiple_owners,
    has_legal_disputes,
    is_negotiable,
    floor,
    has_balcony,
    balcony_count,
    is_furnished,
    has_car_parking,
    expenses,
    photos,
    status,
    notes,
    created_at,
    updated_at,
    createdAt,
    updatedAt,
  }) : _property_name = property_name,
       _client_name = client_name,
       _location = location,
       _property_type = property_type,
       _owner_name = owner_name,
       _owner_phone_numbers = owner_phone_numbers,
       _broker_details = broker_details,
       _care_of = care_of,
       _transaction_type = transaction_type,
       _advance_amount = advance_amount,
       _period = period,
       _area = area,
       _price = price,
       _has_multiple_owners = has_multiple_owners,
       _has_legal_disputes = has_legal_disputes,
       _is_negotiable = is_negotiable,
       _floor = floor,
       _has_balcony = has_balcony,
       _balcony_count = balcony_count,
       _is_furnished = is_furnished,
       _has_car_parking = has_car_parking,
       _expenses = expenses,
       _photos = photos,
       _status = status,
       _notes = notes,
       _created_at = created_at,
       _updated_at = updated_at,
       _createdAt = createdAt,
       _updatedAt = updatedAt;

  factory Properties({
    String? id,
    String? property_name,
    String? client_name,
    String? location,
    String? property_type,
    String? owner_name,
    List<String>? owner_phone_numbers,
    String? broker_details,
    String? care_of,
    String? transaction_type,
    double? advance_amount,
    String? period,
    String? area,
    double? price,
    bool? has_multiple_owners,
    bool? has_legal_disputes,
    bool? is_negotiable,
    String? floor,
    bool? has_balcony,
    int? balcony_count,
    bool? is_furnished,
    bool? has_car_parking,
    String? expenses,
    List<String>? photos,
    String? status,
    String? notes,
    String? created_at,
    String? updated_at,
  }) {
    return Properties._internal(
      id: id == null ? amplify_core.UUID.getUUID() : id,
      property_name: property_name,
      client_name: client_name,
      location: location,
      property_type: property_type,
      owner_name: owner_name,
      owner_phone_numbers: owner_phone_numbers,
      broker_details: broker_details,
      care_of: care_of,
      transaction_type: transaction_type,
      advance_amount: advance_amount,
      period: period,
      area: area,
      price: price,
      has_multiple_owners: has_multiple_owners,
      has_legal_disputes: has_legal_disputes,
      is_negotiable: is_negotiable,
      floor: floor,
      has_balcony: has_balcony,
      balcony_count: balcony_count,
      is_furnished: is_furnished,
      has_car_parking: has_car_parking,
      expenses: expenses,
      photos: photos,
      status: status,
      notes: notes,
      created_at: created_at,
      updated_at: updated_at,
    );
  }

  bool equals(Object other) => this == other;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Properties &&
        id == other.id &&
        _property_name == other._property_name &&
        _client_name == other._client_name &&
        _location == other._location &&
        _property_type == other._property_type &&
        _owner_name == other._owner_name &&
        DeepCollectionEquality().equals(
          _owner_phone_numbers,
          other._owner_phone_numbers,
        ) &&
        _broker_details == other._broker_details &&
        _care_of == other._care_of &&
        _area == other._area &&
        _price == other._price &&
        _is_negotiable == other._is_negotiable &&
        _floor == other._floor &&
        _has_balcony == other._has_balcony &&
        _balcony_count == other._balcony_count &&
        _is_furnished == other._is_furnished &&
        _has_car_parking == other._has_car_parking &&
        _expenses == other._expenses &&
        DeepCollectionEquality().equals(_photos, other._photos) &&
        _status == other._status &&
        _notes == other._notes &&
        _created_at == other._created_at &&
        _updated_at == other._updated_at;
  }

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() {
    var buffer = new StringBuffer();
    buffer.write("Properties {");
    buffer.write("id=" + "$id" + ", ");
    buffer.write(
      "property_name=" +
          (_property_name != null ? _property_name!.toString() : "null") +
          ", ",
    );
    buffer.write(
      "client_name=" +
          (_client_name != null ? _client_name!.toString() : "null") +
          ", ",
    );
    buffer.write(
      "location=" + (_location != null ? _location!.toString() : "null") + ", ",
    );
    buffer.write(
      "property_type=" +
          (_property_type != null ? _property_type!.toString() : "null") +
          ", ",
    );
    buffer.write(
      "owner_name=" +
          (_owner_name != null ? _owner_name!.toString() : "null") +
          ", ",
    );
    buffer.write(
      "owner_phone_numbers=" +
          (_owner_phone_numbers != null
              ? _owner_phone_numbers!.toString()
              : "null") +
          ", ",
    );
    buffer.write(
      "broker_details=" +
          (_broker_details != null ? _broker_details!.toString() : "null") +
          ", ",
    );
    buffer.write(
      "care_of=" + (_care_of != null ? _care_of!.toString() : "null") + ", ",
    );
    buffer.write("area=" + (_area != null ? _area!.toString() : "null") + ", ");
    buffer.write(
      "price=" + (_price != null ? _price!.toString() : "null") + ", ",
    );
    buffer.write(
      "is_negotiable=" +
          (_is_negotiable != null ? _is_negotiable!.toString() : "null") +
          ", ",
    );
    buffer.write(
      "floor=" + (_floor != null ? _floor!.toString() : "null") + ", ",
    );
    buffer.write(
      "has_balcony=" +
          (_has_balcony != null ? _has_balcony!.toString() : "null") +
          ", ",
    );
    buffer.write(
      "balcony_count=" +
          (_balcony_count != null ? _balcony_count!.toString() : "null") +
          ", ",
    );
    buffer.write(
      "is_furnished=" +
          (_is_furnished != null ? _is_furnished!.toString() : "null") +
          ", ",
    );
    buffer.write(
      "has_car_parking=" +
          (_has_car_parking != null ? _has_car_parking!.toString() : "null") +
          ", ",
    );
    buffer.write(
      "expenses=" + (_expenses != null ? _expenses!.toString() : "null") + ", ",
    );
    buffer.write(
      "photos=" + (_photos != null ? _photos!.toString() : "null") + ", ",
    );
    buffer.write(
      "status=" + (_status != null ? _status!.toString() : "null") + ", ",
    );
    buffer.write(
      "notes=" + (_notes != null ? _notes!.toString() : "null") + ", ",
    );
    buffer.write(
      "created_at=" +
          (_created_at != null ? _created_at!.toString() : "null") +
          ", ",
    );
    buffer.write(
      "updated_at=" +
          (_updated_at != null ? _updated_at!.toString() : "null") +
          ", ",
    );
    buffer.write("}");
    return buffer.toString();
  }

  Properties copyWith({
    String? property_name,
    String? client_name,
    String? location,
    String? property_type,
    String? owner_name,
    List<String>? owner_phone_numbers,
    String? broker_details,
    String? care_of,
    String? transaction_type,
    double? advance_amount,
    String? period,
    String? area,
    double? price,
    bool? has_multiple_owners,
    bool? has_legal_disputes,
    bool? is_negotiable,
    String? floor,
    bool? has_balcony,
    int? balcony_count,
    bool? is_furnished,
    bool? has_car_parking,
    String? expenses,
    List<String>? photos,
    String? status,
    String? notes,
    String? created_at,
    String? updated_at,
  }) {
    return Properties._internal(
      id: id,
      property_name: property_name ?? this.property_name,
      client_name: client_name ?? this.client_name,
      location: location ?? this.location,
      property_type: property_type ?? this.property_type,
      owner_name: owner_name ?? this.owner_name,
      owner_phone_numbers: owner_phone_numbers ?? this.owner_phone_numbers,
      broker_details: broker_details ?? this.broker_details,
      care_of: care_of ?? this.care_of,
      transaction_type: transaction_type ?? this.transaction_type,
      advance_amount: advance_amount ?? this.advance_amount,
      period: period ?? this.period,
      area: area ?? this.area,
      price: price ?? this.price,
      has_multiple_owners: has_multiple_owners ?? this.has_multiple_owners,
      has_legal_disputes: has_legal_disputes ?? this.has_legal_disputes,
      is_negotiable: is_negotiable ?? this.is_negotiable,
      floor: floor ?? this.floor,
      has_balcony: has_balcony ?? this.has_balcony,
      balcony_count: balcony_count ?? this.balcony_count,
      is_furnished: is_furnished ?? this.is_furnished,
      has_car_parking: has_car_parking ?? this.has_car_parking,
      expenses: expenses ?? this.expenses,
      photos: photos ?? this.photos,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
    );
  }

  Properties copyWithModelFieldValues({
    ModelFieldValue<String?>? property_name,
    ModelFieldValue<String?>? client_name,
    ModelFieldValue<String?>? location,
    ModelFieldValue<String?>? property_type,
    ModelFieldValue<String?>? owner_name,
    ModelFieldValue<List<String>?>? owner_phone_numbers,
    ModelFieldValue<String?>? broker_details,
    ModelFieldValue<String?>? care_of,
    ModelFieldValue<String?>? area,
    ModelFieldValue<double?>? price,
    ModelFieldValue<bool?>? is_negotiable,
    ModelFieldValue<String?>? floor,
    ModelFieldValue<bool?>? has_balcony,
    ModelFieldValue<int?>? balcony_count,
    ModelFieldValue<bool?>? is_furnished,
    ModelFieldValue<bool?>? has_car_parking,
    ModelFieldValue<String?>? expenses,
    ModelFieldValue<List<String>?>? photos,
    ModelFieldValue<String?>? status,
    ModelFieldValue<String?>? notes,
    ModelFieldValue<String?>? created_at,
    ModelFieldValue<String?>? updated_at,
  }) {
    return Properties._internal(
      id: id,
      property_name: property_name == null
          ? this.property_name
          : property_name.value,
      client_name: client_name == null ? this.client_name : client_name.value,
      location: location == null ? this.location : location.value,
      property_type: property_type == null
          ? this.property_type
          : property_type.value,
      owner_name: owner_name == null ? this.owner_name : owner_name.value,
      owner_phone_numbers: owner_phone_numbers == null
          ? this.owner_phone_numbers
          : owner_phone_numbers.value,
      broker_details: broker_details == null
          ? this.broker_details
          : broker_details.value,
      care_of: care_of == null ? this.care_of : care_of.value,
      area: area == null ? this.area : area.value,
      price: price == null ? this.price : price.value,
      is_negotiable: is_negotiable == null
          ? this.is_negotiable
          : is_negotiable.value,
      floor: floor == null ? this.floor : floor.value,
      has_balcony: has_balcony == null ? this.has_balcony : has_balcony.value,
      balcony_count: balcony_count == null
          ? this.balcony_count
          : balcony_count.value,
      is_furnished: is_furnished == null
          ? this.is_furnished
          : is_furnished.value,
      has_car_parking: has_car_parking == null
          ? this.has_car_parking
          : has_car_parking.value,
      expenses: expenses == null ? this.expenses : expenses.value,
      photos: photos == null ? this.photos : photos.value,
      status: status == null ? this.status : status.value,
      notes: notes == null ? this.notes : notes.value,
      created_at: created_at == null ? this.created_at : created_at.value,
      updated_at: updated_at == null ? this.updated_at : updated_at.value,
    );
  }

  Properties.fromJson(Map<String, dynamic> jsonData)
    : id = jsonData['id'],
      _property_name = jsonData['property_name'],
      _client_name = jsonData['client_name'],
      _location = jsonData['location'],
      _property_type = jsonData['property_type'],
      _owner_name = jsonData['owner_name'],
      _owner_phone_numbers = jsonData['owner_phone_numbers']?.cast<String>(),
      _broker_details = jsonData['broker_details'],
      _care_of = jsonData['care_of'],
      _transaction_type = jsonData['transaction_type'],
      _advance_amount = (jsonData['advance_amount'] as num?)?.toDouble(),
      _period = jsonData['period'],
      _area = jsonData['area'],
      _price = (jsonData['price'] as num?)?.toDouble(),
      _has_multiple_owners = jsonData['has_multiple_owners'],
      _has_legal_disputes = jsonData['has_legal_disputes'],
      _is_negotiable = jsonData['is_negotiable'],
      _floor = jsonData['floor'],
      _has_balcony = jsonData['has_balcony'],
      _balcony_count = jsonData['balcony_count'],
      _is_furnished = jsonData['is_furnished'],
      _has_car_parking = jsonData['has_car_parking'],
      _expenses = jsonData['expenses'],
      _photos = jsonData['photos']?.cast<String>(),
      _status = jsonData['status'],
      _notes = jsonData['notes'],
      _created_at = jsonData['created_at'],
      _updated_at = jsonData['updated_at'],
      _createdAt = jsonData['createdAt'] != null
          ? amplify_core.TemporalDateTime.fromString(jsonData['createdAt'])
          : null,
      _updatedAt = jsonData['updatedAt'] != null
          ? amplify_core.TemporalDateTime.fromString(jsonData['updatedAt'])
          : null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'property_name': _property_name,
    'client_name': _client_name,
    'location': _location,
    'property_type': _property_type,
    'owner_name': _owner_name,
    'owner_phone_numbers': _owner_phone_numbers,
    'broker_details': _broker_details,
    'care_of': _care_of,
    'area': _area,
    'price': _price,
    'is_negotiable': _is_negotiable,
    'floor': _floor,
    'has_balcony': _has_balcony,
    'balcony_count': _balcony_count,
    'is_furnished': _is_furnished,
    'has_car_parking': _has_car_parking,
    'expenses': _expenses,
    'photos': _photos,
    'status': _status,
    'notes': _notes,
    'created_at': _created_at,
    'updated_at': _updated_at,
    'createdAt': _createdAt?.format(),
    'updatedAt': _updatedAt?.format(),
  };

  Map<String, Object?> toMap() => {
    'id': id,
    'property_name': _property_name,
    'client_name': _client_name,
    'location': _location,
    'property_type': _property_type,
    'owner_name': _owner_name,
    'owner_phone_numbers': _owner_phone_numbers,
    'broker_details': _broker_details,
    'care_of': _care_of,
    'area': _area,
    'price': _price,
    'is_negotiable': _is_negotiable,
    'floor': _floor,
    'has_balcony': _has_balcony,
    'balcony_count': _balcony_count,
    'is_furnished': _is_furnished,
    'has_car_parking': _has_car_parking,
    'expenses': _expenses,
    'photos': _photos,
    'status': _status,
    'notes': _notes,
    'created_at': _created_at,
    'updated_at': _updated_at,
    'createdAt': _createdAt,
    'updatedAt': _updatedAt,
  };

  static final amplify_core.QueryModelIdentifier<PropertiesModelIdentifier>
  MODEL_IDENTIFIER =
      amplify_core.QueryModelIdentifier<PropertiesModelIdentifier>();
  static final ID = amplify_core.QueryField(fieldName: "id");
  static final PROPERTY_NAME = amplify_core.QueryField(
    fieldName: "property_name",
  );
  static final CLIENT_NAME = amplify_core.QueryField(fieldName: "client_name");
  static final LOCATION = amplify_core.QueryField(fieldName: "location");
  static final PROPERTY_TYPE = amplify_core.QueryField(
    fieldName: "property_type",
  );
  static final OWNER_NAME = amplify_core.QueryField(fieldName: "owner_name");
  static final OWNER_PHONE_NUMBERS = amplify_core.QueryField(
    fieldName: "owner_phone_numbers",
  );
  static final BROKER_DETAILS = amplify_core.QueryField(
    fieldName: "broker_details",
  );
  static final CARE_OF = amplify_core.QueryField(fieldName: "care_of");
  static final AREA = amplify_core.QueryField(fieldName: "area");
  static final PRICE = amplify_core.QueryField(fieldName: "price");
  static final IS_NEGOTIABLE = amplify_core.QueryField(
    fieldName: "is_negotiable",
  );
  static final FLOOR = amplify_core.QueryField(fieldName: "floor");
  static final HAS_BALCONY = amplify_core.QueryField(fieldName: "has_balcony");
  static final BALCONY_COUNT = amplify_core.QueryField(
    fieldName: "balcony_count",
  );
  static final IS_FURNISHED = amplify_core.QueryField(
    fieldName: "is_furnished",
  );
  static final HAS_CAR_PARKING = amplify_core.QueryField(
    fieldName: "has_car_parking",
  );
  static final EXPENSES = amplify_core.QueryField(fieldName: "expenses");
  static final PHOTOS = amplify_core.QueryField(fieldName: "photos");
  static final STATUS = amplify_core.QueryField(fieldName: "status");
  static final NOTES = amplify_core.QueryField(fieldName: "notes");
  static final CREATED_AT = amplify_core.QueryField(fieldName: "created_at");
  static final UPDATED_AT = amplify_core.QueryField(fieldName: "updated_at");
  static var schema = amplify_core.Model.defineSchema(
    define: (amplify_core.ModelSchemaDefinition modelSchemaDefinition) {
      modelSchemaDefinition.name = "Properties";
      modelSchemaDefinition.pluralName = "Properties";

      modelSchemaDefinition.authRules = [
        amplify_core.AuthRule(
          authStrategy: amplify_core.AuthStrategy.PRIVATE,
          provider: amplify_core.AuthRuleProvider.IAM,
          operations: const [
            amplify_core.ModelOperation.CREATE,
            amplify_core.ModelOperation.UPDATE,
            amplify_core.ModelOperation.DELETE,
            amplify_core.ModelOperation.READ,
          ],
        ),
      ];

      modelSchemaDefinition.addField(amplify_core.ModelFieldDefinition.id());
      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Properties.PROPERTY_NAME,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );
      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Properties.CLIENT_NAME,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );
      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Properties.LOCATION,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );
      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Properties.PROPERTY_TYPE,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );
      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Properties.OWNER_NAME,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );
      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.customTypeField(
          fieldName: 'owner_phone_numbers',
          isRequired: false,
          isArray: true,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.collection,
            ofModelName: amplify_core.ModelFieldTypeEnum.string.name,
          ),
        ),
      );
      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Properties.BROKER_DETAILS,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );
      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Properties.CARE_OF,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );
      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Properties.AREA,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );
      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Properties.PRICE,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.double,
          ),
        ),
      );
      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Properties.IS_NEGOTIABLE,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.bool,
          ),
        ),
      );
      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Properties.FLOOR,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );
      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Properties.HAS_BALCONY,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.bool,
          ),
        ),
      );
      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Properties.BALCONY_COUNT,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.int,
          ),
        ),
      );
      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Properties.IS_FURNISHED,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.bool,
          ),
        ),
      );
      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Properties.HAS_CAR_PARKING,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.bool,
          ),
        ),
      );
      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Properties.EXPENSES,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );
      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.customTypeField(
          fieldName: 'photos',
          isRequired: false,
          isArray: true,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.collection,
            ofModelName: amplify_core.ModelFieldTypeEnum.string.name,
          ),
        ),
      );
      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Properties.STATUS,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );
      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Properties.NOTES,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );
      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Properties.CREATED_AT,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );
      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.field(
          key: Properties.UPDATED_AT,
          isRequired: false,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.string,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.nonQueryField(
          fieldName: 'createdAt',
          isRequired: false,
          isReadOnly: true,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.dateTime,
          ),
        ),
      );

      modelSchemaDefinition.addField(
        amplify_core.ModelFieldDefinition.nonQueryField(
          fieldName: 'updatedAt',
          isRequired: false,
          isReadOnly: true,
          ofType: amplify_core.ModelFieldType(
            amplify_core.ModelFieldTypeEnum.dateTime,
          ),
        ),
      );
    },
  );
}

class _PropertiesModelType extends amplify_core.ModelType<Properties> {
  const _PropertiesModelType();

  @override
  Properties fromJson(Map<String, dynamic> jsonData) {
    return Properties.fromJson(jsonData);
  }

  @override
  String modelName() {
    return 'Properties';
  }
}

class PropertiesModelIdentifier
    implements amplify_core.ModelIdentifier<Properties> {
  final String id;
  const PropertiesModelIdentifier({required this.id});

  @override
  Map<String, dynamic> serializeAsMap() => (<String, dynamic>{'id': id});

  @override
  List<Map<String, dynamic>> serializeAsList() => serializeAsMap().entries
      .map((entry) => (<String, dynamic>{entry.key: entry.value}))
      .toList();

  @override
  String serializeAsString() => serializeAsMap().values.join('#');

  @override
  String toString() => 'PropertiesModelIdentifier(id: $id)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is PropertiesModelIdentifier && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
