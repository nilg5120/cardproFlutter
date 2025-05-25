// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PokemonCardsTable extends PokemonCards
    with TableInfo<$PokemonCardsTable, PokemonCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PokemonCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rarityMeta = const VerificationMeta('rarity');
  @override
  late final GeneratedColumn<String> rarity = GeneratedColumn<String>(
    'rarity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _setNameMeta = const VerificationMeta(
    'setName',
  );
  @override
  late final GeneratedColumn<String> setName = GeneratedColumn<String>(
    'set_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cardnumberMeta = const VerificationMeta(
    'cardnumber',
  );
  @override
  late final GeneratedColumn<int> cardnumber = GeneratedColumn<int>(
    'cardnumber',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, rarity, setName, cardnumber];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pokemon_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<PokemonCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('rarity')) {
      context.handle(
        _rarityMeta,
        rarity.isAcceptableOrUnknown(data['rarity']!, _rarityMeta),
      );
    }
    if (data.containsKey('set_name')) {
      context.handle(
        _setNameMeta,
        setName.isAcceptableOrUnknown(data['set_name']!, _setNameMeta),
      );
    }
    if (data.containsKey('cardnumber')) {
      context.handle(
        _cardnumberMeta,
        cardnumber.isAcceptableOrUnknown(data['cardnumber']!, _cardnumberMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PokemonCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PokemonCard(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      rarity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rarity'],
      ),
      setName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_name'],
      ),
      cardnumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cardnumber'],
      ),
    );
  }

  @override
  $PokemonCardsTable createAlias(String alias) {
    return $PokemonCardsTable(attachedDatabase, alias);
  }
}

class PokemonCard extends DataClass implements Insertable<PokemonCard> {
  final int id;
  final String name;
  final String? rarity;
  final String? setName;
  final int? cardnumber;
  const PokemonCard({
    required this.id,
    required this.name,
    this.rarity,
    this.setName,
    this.cardnumber,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || rarity != null) {
      map['rarity'] = Variable<String>(rarity);
    }
    if (!nullToAbsent || setName != null) {
      map['set_name'] = Variable<String>(setName);
    }
    if (!nullToAbsent || cardnumber != null) {
      map['cardnumber'] = Variable<int>(cardnumber);
    }
    return map;
  }

  PokemonCardsCompanion toCompanion(bool nullToAbsent) {
    return PokemonCardsCompanion(
      id: Value(id),
      name: Value(name),
      rarity:
          rarity == null && nullToAbsent ? const Value.absent() : Value(rarity),
      setName:
          setName == null && nullToAbsent
              ? const Value.absent()
              : Value(setName),
      cardnumber:
          cardnumber == null && nullToAbsent
              ? const Value.absent()
              : Value(cardnumber),
    );
  }

  factory PokemonCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PokemonCard(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      rarity: serializer.fromJson<String?>(json['rarity']),
      setName: serializer.fromJson<String?>(json['setName']),
      cardnumber: serializer.fromJson<int?>(json['cardnumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'rarity': serializer.toJson<String?>(rarity),
      'setName': serializer.toJson<String?>(setName),
      'cardnumber': serializer.toJson<int?>(cardnumber),
    };
  }

  PokemonCard copyWith({
    int? id,
    String? name,
    Value<String?> rarity = const Value.absent(),
    Value<String?> setName = const Value.absent(),
    Value<int?> cardnumber = const Value.absent(),
  }) => PokemonCard(
    id: id ?? this.id,
    name: name ?? this.name,
    rarity: rarity.present ? rarity.value : this.rarity,
    setName: setName.present ? setName.value : this.setName,
    cardnumber: cardnumber.present ? cardnumber.value : this.cardnumber,
  );
  PokemonCard copyWithCompanion(PokemonCardsCompanion data) {
    return PokemonCard(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      rarity: data.rarity.present ? data.rarity.value : this.rarity,
      setName: data.setName.present ? data.setName.value : this.setName,
      cardnumber:
          data.cardnumber.present ? data.cardnumber.value : this.cardnumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PokemonCard(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rarity: $rarity, ')
          ..write('setName: $setName, ')
          ..write('cardnumber: $cardnumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, rarity, setName, cardnumber);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PokemonCard &&
          other.id == this.id &&
          other.name == this.name &&
          other.rarity == this.rarity &&
          other.setName == this.setName &&
          other.cardnumber == this.cardnumber);
}

class PokemonCardsCompanion extends UpdateCompanion<PokemonCard> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> rarity;
  final Value<String?> setName;
  final Value<int?> cardnumber;
  const PokemonCardsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rarity = const Value.absent(),
    this.setName = const Value.absent(),
    this.cardnumber = const Value.absent(),
  });
  PokemonCardsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.rarity = const Value.absent(),
    this.setName = const Value.absent(),
    this.cardnumber = const Value.absent(),
  }) : name = Value(name);
  static Insertable<PokemonCard> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? rarity,
    Expression<String>? setName,
    Expression<int>? cardnumber,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rarity != null) 'rarity': rarity,
      if (setName != null) 'set_name': setName,
      if (cardnumber != null) 'cardnumber': cardnumber,
    });
  }

  PokemonCardsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? rarity,
    Value<String?>? setName,
    Value<int?>? cardnumber,
  }) {
    return PokemonCardsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rarity: rarity ?? this.rarity,
      setName: setName ?? this.setName,
      cardnumber: cardnumber ?? this.cardnumber,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rarity.present) {
      map['rarity'] = Variable<String>(rarity.value);
    }
    if (setName.present) {
      map['set_name'] = Variable<String>(setName.value);
    }
    if (cardnumber.present) {
      map['cardnumber'] = Variable<int>(cardnumber.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PokemonCardsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rarity: $rarity, ')
          ..write('setName: $setName, ')
          ..write('cardnumber: $cardnumber')
          ..write(')'))
        .toString();
  }
}

class $CardInstancesTable extends CardInstances
    with TableInfo<$CardInstancesTable, CardInstance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardInstancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<int> cardId = GeneratedColumn<int>(
    'card_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, cardId, updatedAt, description];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_instances';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardInstance> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_id')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardInstance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardInstance(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      cardId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}card_id'],
          )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
    );
  }

  @override
  $CardInstancesTable createAlias(String alias) {
    return $CardInstancesTable(attachedDatabase, alias);
  }
}

class CardInstance extends DataClass implements Insertable<CardInstance> {
  final int id;
  final int cardId;
  final DateTime? updatedAt;
  final String? description;
  const CardInstance({
    required this.id,
    required this.cardId,
    this.updatedAt,
    this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_id'] = Variable<int>(cardId);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    return map;
  }

  CardInstancesCompanion toCompanion(bool nullToAbsent) {
    return CardInstancesCompanion(
      id: Value(id),
      cardId: Value(cardId),
      updatedAt:
          updatedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(updatedAt),
      description:
          description == null && nullToAbsent
              ? const Value.absent()
              : Value(description),
    );
  }

  factory CardInstance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardInstance(
      id: serializer.fromJson<int>(json['id']),
      cardId: serializer.fromJson<int>(json['cardId']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
      description: serializer.fromJson<String?>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardId': serializer.toJson<int>(cardId),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
      'description': serializer.toJson<String?>(description),
    };
  }

  CardInstance copyWith({
    int? id,
    int? cardId,
    Value<DateTime?> updatedAt = const Value.absent(),
    Value<String?> description = const Value.absent(),
  }) => CardInstance(
    id: id ?? this.id,
    cardId: cardId ?? this.cardId,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    description: description.present ? description.value : this.description,
  );
  CardInstance copyWithCompanion(CardInstancesCompanion data) {
    return CardInstance(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      description:
          data.description.present ? data.description.value : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardInstance(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cardId, updatedAt, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardInstance &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.updatedAt == this.updatedAt &&
          other.description == this.description);
}

class CardInstancesCompanion extends UpdateCompanion<CardInstance> {
  final Value<int> id;
  final Value<int> cardId;
  final Value<DateTime?> updatedAt;
  final Value<String?> description;
  const CardInstancesCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.description = const Value.absent(),
  });
  CardInstancesCompanion.insert({
    this.id = const Value.absent(),
    required int cardId,
    this.updatedAt = const Value.absent(),
    this.description = const Value.absent(),
  }) : cardId = Value(cardId);
  static Insertable<CardInstance> custom({
    Expression<int>? id,
    Expression<int>? cardId,
    Expression<DateTime>? updatedAt,
    Expression<String>? description,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (description != null) 'description': description,
    });
  }

  CardInstancesCompanion copyWith({
    Value<int>? id,
    Value<int>? cardId,
    Value<DateTime?>? updatedAt,
    Value<String?>? description,
  }) {
    return CardInstancesCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      updatedAt: updatedAt ?? this.updatedAt,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<int>(cardId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardInstancesCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }
}

class $ContainersTable extends Containers
    with TableInfo<$ContainersTable, Container> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContainersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _containerTypeMeta = const VerificationMeta(
    'containerType',
  );
  @override
  late final GeneratedColumn<String> containerType = GeneratedColumn<String>(
    'container_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, description, containerType];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'containers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Container> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('container_type')) {
      context.handle(
        _containerTypeMeta,
        containerType.isAcceptableOrUnknown(
          data['container_type']!,
          _containerTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_containerTypeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Container map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Container(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      containerType:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}container_type'],
          )!,
    );
  }

  @override
  $ContainersTable createAlias(String alias) {
    return $ContainersTable(attachedDatabase, alias);
  }
}

class Container extends DataClass implements Insertable<Container> {
  final int id;
  final String? name;
  final String? description;
  final String containerType;
  const Container({
    required this.id,
    this.name,
    this.description,
    required this.containerType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['container_type'] = Variable<String>(containerType);
    return map;
  }

  ContainersCompanion toCompanion(bool nullToAbsent) {
    return ContainersCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      description:
          description == null && nullToAbsent
              ? const Value.absent()
              : Value(description),
      containerType: Value(containerType),
    );
  }

  factory Container.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Container(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      containerType: serializer.fromJson<String>(json['containerType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String?>(name),
      'description': serializer.toJson<String?>(description),
      'containerType': serializer.toJson<String>(containerType),
    };
  }

  Container copyWith({
    int? id,
    Value<String?> name = const Value.absent(),
    Value<String?> description = const Value.absent(),
    String? containerType,
  }) => Container(
    id: id ?? this.id,
    name: name.present ? name.value : this.name,
    description: description.present ? description.value : this.description,
    containerType: containerType ?? this.containerType,
  );
  Container copyWithCompanion(ContainersCompanion data) {
    return Container(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      containerType:
          data.containerType.present
              ? data.containerType.value
              : this.containerType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Container(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('containerType: $containerType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, containerType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Container &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.containerType == this.containerType);
}

class ContainersCompanion extends UpdateCompanion<Container> {
  final Value<int> id;
  final Value<String?> name;
  final Value<String?> description;
  final Value<String> containerType;
  const ContainersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.containerType = const Value.absent(),
  });
  ContainersCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    required String containerType,
  }) : containerType = Value(containerType);
  static Insertable<Container> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? containerType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (containerType != null) 'container_type': containerType,
    });
  }

  ContainersCompanion copyWith({
    Value<int>? id,
    Value<String?>? name,
    Value<String?>? description,
    Value<String>? containerType,
  }) {
    return ContainersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      containerType: containerType ?? this.containerType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (containerType.present) {
      map['container_type'] = Variable<String>(containerType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContainersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('containerType: $containerType')
          ..write(')'))
        .toString();
  }
}

class $DeckCardLocationsTable extends DeckCardLocations
    with TableInfo<$DeckCardLocationsTable, DeckCardLocation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeckCardLocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _containerIdMeta = const VerificationMeta(
    'containerId',
  );
  @override
  late final GeneratedColumn<int> containerId = GeneratedColumn<int>(
    'container_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardInstanceIdMeta = const VerificationMeta(
    'cardInstanceId',
  );
  @override
  late final GeneratedColumn<String> cardInstanceId = GeneratedColumn<String>(
    'card_instance_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [containerId, cardInstanceId, location];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deck_card_locations';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeckCardLocation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('container_id')) {
      context.handle(
        _containerIdMeta,
        containerId.isAcceptableOrUnknown(
          data['container_id']!,
          _containerIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_containerIdMeta);
    }
    if (data.containsKey('card_instance_id')) {
      context.handle(
        _cardInstanceIdMeta,
        cardInstanceId.isAcceptableOrUnknown(
          data['card_instance_id']!,
          _cardInstanceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cardInstanceIdMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    containerId,
    cardInstanceId,
    location,
  };
  @override
  DeckCardLocation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeckCardLocation(
      containerId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}container_id'],
          )!,
      cardInstanceId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}card_instance_id'],
          )!,
      location:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}location'],
          )!,
    );
  }

  @override
  $DeckCardLocationsTable createAlias(String alias) {
    return $DeckCardLocationsTable(attachedDatabase, alias);
  }
}

class DeckCardLocation extends DataClass
    implements Insertable<DeckCardLocation> {
  final int containerId;
  final String cardInstanceId;
  final String location;
  const DeckCardLocation({
    required this.containerId,
    required this.cardInstanceId,
    required this.location,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['container_id'] = Variable<int>(containerId);
    map['card_instance_id'] = Variable<String>(cardInstanceId);
    map['location'] = Variable<String>(location);
    return map;
  }

  DeckCardLocationsCompanion toCompanion(bool nullToAbsent) {
    return DeckCardLocationsCompanion(
      containerId: Value(containerId),
      cardInstanceId: Value(cardInstanceId),
      location: Value(location),
    );
  }

  factory DeckCardLocation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeckCardLocation(
      containerId: serializer.fromJson<int>(json['containerId']),
      cardInstanceId: serializer.fromJson<String>(json['cardInstanceId']),
      location: serializer.fromJson<String>(json['location']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'containerId': serializer.toJson<int>(containerId),
      'cardInstanceId': serializer.toJson<String>(cardInstanceId),
      'location': serializer.toJson<String>(location),
    };
  }

  DeckCardLocation copyWith({
    int? containerId,
    String? cardInstanceId,
    String? location,
  }) => DeckCardLocation(
    containerId: containerId ?? this.containerId,
    cardInstanceId: cardInstanceId ?? this.cardInstanceId,
    location: location ?? this.location,
  );
  DeckCardLocation copyWithCompanion(DeckCardLocationsCompanion data) {
    return DeckCardLocation(
      containerId:
          data.containerId.present ? data.containerId.value : this.containerId,
      cardInstanceId:
          data.cardInstanceId.present
              ? data.cardInstanceId.value
              : this.cardInstanceId,
      location: data.location.present ? data.location.value : this.location,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeckCardLocation(')
          ..write('containerId: $containerId, ')
          ..write('cardInstanceId: $cardInstanceId, ')
          ..write('location: $location')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(containerId, cardInstanceId, location);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeckCardLocation &&
          other.containerId == this.containerId &&
          other.cardInstanceId == this.cardInstanceId &&
          other.location == this.location);
}

class DeckCardLocationsCompanion extends UpdateCompanion<DeckCardLocation> {
  final Value<int> containerId;
  final Value<String> cardInstanceId;
  final Value<String> location;
  final Value<int> rowid;
  const DeckCardLocationsCompanion({
    this.containerId = const Value.absent(),
    this.cardInstanceId = const Value.absent(),
    this.location = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeckCardLocationsCompanion.insert({
    required int containerId,
    required String cardInstanceId,
    required String location,
    this.rowid = const Value.absent(),
  }) : containerId = Value(containerId),
       cardInstanceId = Value(cardInstanceId),
       location = Value(location);
  static Insertable<DeckCardLocation> custom({
    Expression<int>? containerId,
    Expression<String>? cardInstanceId,
    Expression<String>? location,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (containerId != null) 'container_id': containerId,
      if (cardInstanceId != null) 'card_instance_id': cardInstanceId,
      if (location != null) 'location': location,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeckCardLocationsCompanion copyWith({
    Value<int>? containerId,
    Value<String>? cardInstanceId,
    Value<String>? location,
    Value<int>? rowid,
  }) {
    return DeckCardLocationsCompanion(
      containerId: containerId ?? this.containerId,
      cardInstanceId: cardInstanceId ?? this.cardInstanceId,
      location: location ?? this.location,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (containerId.present) {
      map['container_id'] = Variable<int>(containerId.value);
    }
    if (cardInstanceId.present) {
      map['card_instance_id'] = Variable<String>(cardInstanceId.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeckCardLocationsCompanion(')
          ..write('containerId: $containerId, ')
          ..write('cardInstanceId: $cardInstanceId, ')
          ..write('location: $location, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PokemonCardsTable pokemonCards = $PokemonCardsTable(this);
  late final $CardInstancesTable cardInstances = $CardInstancesTable(this);
  late final $ContainersTable containers = $ContainersTable(this);
  late final $DeckCardLocationsTable deckCardLocations =
      $DeckCardLocationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    pokemonCards,
    cardInstances,
    containers,
    deckCardLocations,
  ];
}

typedef $$PokemonCardsTableCreateCompanionBuilder =
    PokemonCardsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> rarity,
      Value<String?> setName,
      Value<int?> cardnumber,
    });
typedef $$PokemonCardsTableUpdateCompanionBuilder =
    PokemonCardsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> rarity,
      Value<String?> setName,
      Value<int?> cardnumber,
    });

class $$PokemonCardsTableFilterComposer
    extends Composer<_$AppDatabase, $PokemonCardsTable> {
  $$PokemonCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setName => $composableBuilder(
    column: $table.setName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardnumber => $composableBuilder(
    column: $table.cardnumber,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PokemonCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $PokemonCardsTable> {
  $$PokemonCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rarity => $composableBuilder(
    column: $table.rarity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setName => $composableBuilder(
    column: $table.setName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardnumber => $composableBuilder(
    column: $table.cardnumber,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PokemonCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PokemonCardsTable> {
  $$PokemonCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get rarity =>
      $composableBuilder(column: $table.rarity, builder: (column) => column);

  GeneratedColumn<String> get setName =>
      $composableBuilder(column: $table.setName, builder: (column) => column);

  GeneratedColumn<int> get cardnumber => $composableBuilder(
    column: $table.cardnumber,
    builder: (column) => column,
  );
}

class $$PokemonCardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PokemonCardsTable,
          PokemonCard,
          $$PokemonCardsTableFilterComposer,
          $$PokemonCardsTableOrderingComposer,
          $$PokemonCardsTableAnnotationComposer,
          $$PokemonCardsTableCreateCompanionBuilder,
          $$PokemonCardsTableUpdateCompanionBuilder,
          (
            PokemonCard,
            BaseReferences<_$AppDatabase, $PokemonCardsTable, PokemonCard>,
          ),
          PokemonCard,
          PrefetchHooks Function()
        > {
  $$PokemonCardsTableTableManager(_$AppDatabase db, $PokemonCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$PokemonCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$PokemonCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$PokemonCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> rarity = const Value.absent(),
                Value<String?> setName = const Value.absent(),
                Value<int?> cardnumber = const Value.absent(),
              }) => PokemonCardsCompanion(
                id: id,
                name: name,
                rarity: rarity,
                setName: setName,
                cardnumber: cardnumber,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> rarity = const Value.absent(),
                Value<String?> setName = const Value.absent(),
                Value<int?> cardnumber = const Value.absent(),
              }) => PokemonCardsCompanion.insert(
                id: id,
                name: name,
                rarity: rarity,
                setName: setName,
                cardnumber: cardnumber,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PokemonCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PokemonCardsTable,
      PokemonCard,
      $$PokemonCardsTableFilterComposer,
      $$PokemonCardsTableOrderingComposer,
      $$PokemonCardsTableAnnotationComposer,
      $$PokemonCardsTableCreateCompanionBuilder,
      $$PokemonCardsTableUpdateCompanionBuilder,
      (
        PokemonCard,
        BaseReferences<_$AppDatabase, $PokemonCardsTable, PokemonCard>,
      ),
      PokemonCard,
      PrefetchHooks Function()
    >;
typedef $$CardInstancesTableCreateCompanionBuilder =
    CardInstancesCompanion Function({
      Value<int> id,
      required int cardId,
      Value<DateTime?> updatedAt,
      Value<String?> description,
    });
typedef $$CardInstancesTableUpdateCompanionBuilder =
    CardInstancesCompanion Function({
      Value<int> id,
      Value<int> cardId,
      Value<DateTime?> updatedAt,
      Value<String?> description,
    });

class $$CardInstancesTableFilterComposer
    extends Composer<_$AppDatabase, $CardInstancesTable> {
  $$CardInstancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CardInstancesTableOrderingComposer
    extends Composer<_$AppDatabase, $CardInstancesTable> {
  $$CardInstancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardId => $composableBuilder(
    column: $table.cardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardInstancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardInstancesTable> {
  $$CardInstancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );
}

class $$CardInstancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardInstancesTable,
          CardInstance,
          $$CardInstancesTableFilterComposer,
          $$CardInstancesTableOrderingComposer,
          $$CardInstancesTableAnnotationComposer,
          $$CardInstancesTableCreateCompanionBuilder,
          $$CardInstancesTableUpdateCompanionBuilder,
          (
            CardInstance,
            BaseReferences<_$AppDatabase, $CardInstancesTable, CardInstance>,
          ),
          CardInstance,
          PrefetchHooks Function()
        > {
  $$CardInstancesTableTableManager(_$AppDatabase db, $CardInstancesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$CardInstancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () =>
                  $$CardInstancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$CardInstancesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cardId = const Value.absent(),
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String?> description = const Value.absent(),
              }) => CardInstancesCompanion(
                id: id,
                cardId: cardId,
                updatedAt: updatedAt,
                description: description,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cardId,
                Value<DateTime?> updatedAt = const Value.absent(),
                Value<String?> description = const Value.absent(),
              }) => CardInstancesCompanion.insert(
                id: id,
                cardId: cardId,
                updatedAt: updatedAt,
                description: description,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CardInstancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardInstancesTable,
      CardInstance,
      $$CardInstancesTableFilterComposer,
      $$CardInstancesTableOrderingComposer,
      $$CardInstancesTableAnnotationComposer,
      $$CardInstancesTableCreateCompanionBuilder,
      $$CardInstancesTableUpdateCompanionBuilder,
      (
        CardInstance,
        BaseReferences<_$AppDatabase, $CardInstancesTable, CardInstance>,
      ),
      CardInstance,
      PrefetchHooks Function()
    >;
typedef $$ContainersTableCreateCompanionBuilder =
    ContainersCompanion Function({
      Value<int> id,
      Value<String?> name,
      Value<String?> description,
      required String containerType,
    });
typedef $$ContainersTableUpdateCompanionBuilder =
    ContainersCompanion Function({
      Value<int> id,
      Value<String?> name,
      Value<String?> description,
      Value<String> containerType,
    });

class $$ContainersTableFilterComposer
    extends Composer<_$AppDatabase, $ContainersTable> {
  $$ContainersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get containerType => $composableBuilder(
    column: $table.containerType,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContainersTableOrderingComposer
    extends Composer<_$AppDatabase, $ContainersTable> {
  $$ContainersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get containerType => $composableBuilder(
    column: $table.containerType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContainersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContainersTable> {
  $$ContainersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get containerType => $composableBuilder(
    column: $table.containerType,
    builder: (column) => column,
  );
}

class $$ContainersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContainersTable,
          Container,
          $$ContainersTableFilterComposer,
          $$ContainersTableOrderingComposer,
          $$ContainersTableAnnotationComposer,
          $$ContainersTableCreateCompanionBuilder,
          $$ContainersTableUpdateCompanionBuilder,
          (
            Container,
            BaseReferences<_$AppDatabase, $ContainersTable, Container>,
          ),
          Container,
          PrefetchHooks Function()
        > {
  $$ContainersTableTableManager(_$AppDatabase db, $ContainersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ContainersTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ContainersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ContainersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> containerType = const Value.absent(),
              }) => ContainersCompanion(
                id: id,
                name: name,
                description: description,
                containerType: containerType,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                required String containerType,
              }) => ContainersCompanion.insert(
                id: id,
                name: name,
                description: description,
                containerType: containerType,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContainersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContainersTable,
      Container,
      $$ContainersTableFilterComposer,
      $$ContainersTableOrderingComposer,
      $$ContainersTableAnnotationComposer,
      $$ContainersTableCreateCompanionBuilder,
      $$ContainersTableUpdateCompanionBuilder,
      (Container, BaseReferences<_$AppDatabase, $ContainersTable, Container>),
      Container,
      PrefetchHooks Function()
    >;
typedef $$DeckCardLocationsTableCreateCompanionBuilder =
    DeckCardLocationsCompanion Function({
      required int containerId,
      required String cardInstanceId,
      required String location,
      Value<int> rowid,
    });
typedef $$DeckCardLocationsTableUpdateCompanionBuilder =
    DeckCardLocationsCompanion Function({
      Value<int> containerId,
      Value<String> cardInstanceId,
      Value<String> location,
      Value<int> rowid,
    });

class $$DeckCardLocationsTableFilterComposer
    extends Composer<_$AppDatabase, $DeckCardLocationsTable> {
  $$DeckCardLocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get containerId => $composableBuilder(
    column: $table.containerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardInstanceId => $composableBuilder(
    column: $table.cardInstanceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DeckCardLocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $DeckCardLocationsTable> {
  $$DeckCardLocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get containerId => $composableBuilder(
    column: $table.containerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardInstanceId => $composableBuilder(
    column: $table.cardInstanceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DeckCardLocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeckCardLocationsTable> {
  $$DeckCardLocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get containerId => $composableBuilder(
    column: $table.containerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cardInstanceId => $composableBuilder(
    column: $table.cardInstanceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);
}

class $$DeckCardLocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeckCardLocationsTable,
          DeckCardLocation,
          $$DeckCardLocationsTableFilterComposer,
          $$DeckCardLocationsTableOrderingComposer,
          $$DeckCardLocationsTableAnnotationComposer,
          $$DeckCardLocationsTableCreateCompanionBuilder,
          $$DeckCardLocationsTableUpdateCompanionBuilder,
          (
            DeckCardLocation,
            BaseReferences<
              _$AppDatabase,
              $DeckCardLocationsTable,
              DeckCardLocation
            >,
          ),
          DeckCardLocation,
          PrefetchHooks Function()
        > {
  $$DeckCardLocationsTableTableManager(
    _$AppDatabase db,
    $DeckCardLocationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$DeckCardLocationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer:
              () => $$DeckCardLocationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$DeckCardLocationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> containerId = const Value.absent(),
                Value<String> cardInstanceId = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeckCardLocationsCompanion(
                containerId: containerId,
                cardInstanceId: cardInstanceId,
                location: location,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int containerId,
                required String cardInstanceId,
                required String location,
                Value<int> rowid = const Value.absent(),
              }) => DeckCardLocationsCompanion.insert(
                containerId: containerId,
                cardInstanceId: cardInstanceId,
                location: location,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DeckCardLocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeckCardLocationsTable,
      DeckCardLocation,
      $$DeckCardLocationsTableFilterComposer,
      $$DeckCardLocationsTableOrderingComposer,
      $$DeckCardLocationsTableAnnotationComposer,
      $$DeckCardLocationsTableCreateCompanionBuilder,
      $$DeckCardLocationsTableUpdateCompanionBuilder,
      (
        DeckCardLocation,
        BaseReferences<
          _$AppDatabase,
          $DeckCardLocationsTable,
          DeckCardLocation
        >,
      ),
      DeckCardLocation,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PokemonCardsTableTableManager get pokemonCards =>
      $$PokemonCardsTableTableManager(_db, _db.pokemonCards);
  $$CardInstancesTableTableManager get cardInstances =>
      $$CardInstancesTableTableManager(_db, _db.cardInstances);
  $$ContainersTableTableManager get containers =>
      $$ContainersTableTableManager(_db, _db.containers);
  $$DeckCardLocationsTableTableManager get deckCardLocations =>
      $$DeckCardLocationsTableTableManager(_db, _db.deckCardLocations);
}
