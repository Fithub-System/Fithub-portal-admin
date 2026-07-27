// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalMembersTable extends LocalMembers
    with TableInfo<$LocalMembersTable, LocalMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _powerScoreMeta = const VerificationMeta(
    'powerScore',
  );
  @override
  late final GeneratedColumn<int> powerScore = GeneratedColumn<int>(
    'power_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  static const VerificationMeta _cryptoSaltMeta = const VerificationMeta(
    'cryptoSalt',
  );
  @override
  late final GeneratedColumn<String> cryptoSalt = GeneratedColumn<String>(
    'crypto_salt',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _membershipStatusMeta = const VerificationMeta(
    'membershipStatus',
  );
  @override
  late final GeneratedColumn<String> membershipStatus = GeneratedColumn<String>(
    'membership_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _membershipPlanNameMeta =
      const VerificationMeta('membershipPlanName');
  @override
  late final GeneratedColumn<String> membershipPlanName =
      GeneratedColumn<String>(
        'membership_plan_name',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _membershipEndsAtMeta = const VerificationMeta(
    'membershipEndsAt',
  );
  @override
  late final GeneratedColumn<DateTime> membershipEndsAt =
      GeneratedColumn<DateTime>(
        'membership_ends_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    fullName,
    avatarUrl,
    powerScore,
    cryptoSalt,
    createdAt,
    membershipStatus,
    membershipPlanName,
    membershipEndsAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('power_score')) {
      context.handle(
        _powerScoreMeta,
        powerScore.isAcceptableOrUnknown(data['power_score']!, _powerScoreMeta),
      );
    }
    if (data.containsKey('crypto_salt')) {
      context.handle(
        _cryptoSaltMeta,
        cryptoSalt.isAcceptableOrUnknown(data['crypto_salt']!, _cryptoSaltMeta),
      );
    } else if (isInserting) {
      context.missing(_cryptoSaltMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('membership_status')) {
      context.handle(
        _membershipStatusMeta,
        membershipStatus.isAcceptableOrUnknown(
          data['membership_status']!,
          _membershipStatusMeta,
        ),
      );
    }
    if (data.containsKey('membership_plan_name')) {
      context.handle(
        _membershipPlanNameMeta,
        membershipPlanName.isAcceptableOrUnknown(
          data['membership_plan_name']!,
          _membershipPlanNameMeta,
        ),
      );
    }
    if (data.containsKey('membership_ends_at')) {
      context.handle(
        _membershipEndsAtMeta,
        membershipEndsAt.isAcceptableOrUnknown(
          data['membership_ends_at']!,
          _membershipEndsAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMember(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      powerScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}power_score'],
      )!,
      cryptoSalt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}crypto_salt'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      membershipStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}membership_status'],
      ),
      membershipPlanName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}membership_plan_name'],
      ),
      membershipEndsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}membership_ends_at'],
      ),
    );
  }

  @override
  $LocalMembersTable createAlias(String alias) {
    return $LocalMembersTable(attachedDatabase, alias);
  }
}

class LocalMember extends DataClass implements Insertable<LocalMember> {
  final String id;
  final String tenantId;
  final String fullName;
  final String? avatarUrl;
  final int powerScore;
  final String cryptoSalt;
  final DateTime createdAt;

  /// Cached from `athlete_memberships.status` (FEAT-07 roster sync).
  final String? membershipStatus;
  final String? membershipPlanName;
  final DateTime? membershipEndsAt;
  const LocalMember({
    required this.id,
    required this.tenantId,
    required this.fullName,
    this.avatarUrl,
    required this.powerScore,
    required this.cryptoSalt,
    required this.createdAt,
    this.membershipStatus,
    this.membershipPlanName,
    this.membershipEndsAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['full_name'] = Variable<String>(fullName);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    map['power_score'] = Variable<int>(powerScore);
    map['crypto_salt'] = Variable<String>(cryptoSalt);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || membershipStatus != null) {
      map['membership_status'] = Variable<String>(membershipStatus);
    }
    if (!nullToAbsent || membershipPlanName != null) {
      map['membership_plan_name'] = Variable<String>(membershipPlanName);
    }
    if (!nullToAbsent || membershipEndsAt != null) {
      map['membership_ends_at'] = Variable<DateTime>(membershipEndsAt);
    }
    return map;
  }

  LocalMembersCompanion toCompanion(bool nullToAbsent) {
    return LocalMembersCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      fullName: Value(fullName),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      powerScore: Value(powerScore),
      cryptoSalt: Value(cryptoSalt),
      createdAt: Value(createdAt),
      membershipStatus: membershipStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(membershipStatus),
      membershipPlanName: membershipPlanName == null && nullToAbsent
          ? const Value.absent()
          : Value(membershipPlanName),
      membershipEndsAt: membershipEndsAt == null && nullToAbsent
          ? const Value.absent()
          : Value(membershipEndsAt),
    );
  }

  factory LocalMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMember(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      fullName: serializer.fromJson<String>(json['fullName']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      powerScore: serializer.fromJson<int>(json['powerScore']),
      cryptoSalt: serializer.fromJson<String>(json['cryptoSalt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      membershipStatus: serializer.fromJson<String?>(json['membershipStatus']),
      membershipPlanName: serializer.fromJson<String?>(
        json['membershipPlanName'],
      ),
      membershipEndsAt: serializer.fromJson<DateTime?>(
        json['membershipEndsAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'fullName': serializer.toJson<String>(fullName),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'powerScore': serializer.toJson<int>(powerScore),
      'cryptoSalt': serializer.toJson<String>(cryptoSalt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'membershipStatus': serializer.toJson<String?>(membershipStatus),
      'membershipPlanName': serializer.toJson<String?>(membershipPlanName),
      'membershipEndsAt': serializer.toJson<DateTime?>(membershipEndsAt),
    };
  }

  LocalMember copyWith({
    String? id,
    String? tenantId,
    String? fullName,
    Value<String?> avatarUrl = const Value.absent(),
    int? powerScore,
    String? cryptoSalt,
    DateTime? createdAt,
    Value<String?> membershipStatus = const Value.absent(),
    Value<String?> membershipPlanName = const Value.absent(),
    Value<DateTime?> membershipEndsAt = const Value.absent(),
  }) => LocalMember(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    fullName: fullName ?? this.fullName,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    powerScore: powerScore ?? this.powerScore,
    cryptoSalt: cryptoSalt ?? this.cryptoSalt,
    createdAt: createdAt ?? this.createdAt,
    membershipStatus: membershipStatus.present
        ? membershipStatus.value
        : this.membershipStatus,
    membershipPlanName: membershipPlanName.present
        ? membershipPlanName.value
        : this.membershipPlanName,
    membershipEndsAt: membershipEndsAt.present
        ? membershipEndsAt.value
        : this.membershipEndsAt,
  );
  LocalMember copyWithCompanion(LocalMembersCompanion data) {
    return LocalMember(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      powerScore: data.powerScore.present
          ? data.powerScore.value
          : this.powerScore,
      cryptoSalt: data.cryptoSalt.present
          ? data.cryptoSalt.value
          : this.cryptoSalt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      membershipStatus: data.membershipStatus.present
          ? data.membershipStatus.value
          : this.membershipStatus,
      membershipPlanName: data.membershipPlanName.present
          ? data.membershipPlanName.value
          : this.membershipPlanName,
      membershipEndsAt: data.membershipEndsAt.present
          ? data.membershipEndsAt.value
          : this.membershipEndsAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMember(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('fullName: $fullName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('powerScore: $powerScore, ')
          ..write('cryptoSalt: $cryptoSalt, ')
          ..write('createdAt: $createdAt, ')
          ..write('membershipStatus: $membershipStatus, ')
          ..write('membershipPlanName: $membershipPlanName, ')
          ..write('membershipEndsAt: $membershipEndsAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    fullName,
    avatarUrl,
    powerScore,
    cryptoSalt,
    createdAt,
    membershipStatus,
    membershipPlanName,
    membershipEndsAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMember &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.fullName == this.fullName &&
          other.avatarUrl == this.avatarUrl &&
          other.powerScore == this.powerScore &&
          other.cryptoSalt == this.cryptoSalt &&
          other.createdAt == this.createdAt &&
          other.membershipStatus == this.membershipStatus &&
          other.membershipPlanName == this.membershipPlanName &&
          other.membershipEndsAt == this.membershipEndsAt);
}

class LocalMembersCompanion extends UpdateCompanion<LocalMember> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> fullName;
  final Value<String?> avatarUrl;
  final Value<int> powerScore;
  final Value<String> cryptoSalt;
  final Value<DateTime> createdAt;
  final Value<String?> membershipStatus;
  final Value<String?> membershipPlanName;
  final Value<DateTime?> membershipEndsAt;
  final Value<int> rowid;
  const LocalMembersCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.fullName = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.powerScore = const Value.absent(),
    this.cryptoSalt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.membershipStatus = const Value.absent(),
    this.membershipPlanName = const Value.absent(),
    this.membershipEndsAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMembersCompanion.insert({
    required String id,
    required String tenantId,
    required String fullName,
    this.avatarUrl = const Value.absent(),
    this.powerScore = const Value.absent(),
    required String cryptoSalt,
    required DateTime createdAt,
    this.membershipStatus = const Value.absent(),
    this.membershipPlanName = const Value.absent(),
    this.membershipEndsAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       fullName = Value(fullName),
       cryptoSalt = Value(cryptoSalt),
       createdAt = Value(createdAt);
  static Insertable<LocalMember> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? fullName,
    Expression<String>? avatarUrl,
    Expression<int>? powerScore,
    Expression<String>? cryptoSalt,
    Expression<DateTime>? createdAt,
    Expression<String>? membershipStatus,
    Expression<String>? membershipPlanName,
    Expression<DateTime>? membershipEndsAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (fullName != null) 'full_name': fullName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (powerScore != null) 'power_score': powerScore,
      if (cryptoSalt != null) 'crypto_salt': cryptoSalt,
      if (createdAt != null) 'created_at': createdAt,
      if (membershipStatus != null) 'membership_status': membershipStatus,
      if (membershipPlanName != null)
        'membership_plan_name': membershipPlanName,
      if (membershipEndsAt != null) 'membership_ends_at': membershipEndsAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMembersCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? fullName,
    Value<String?>? avatarUrl,
    Value<int>? powerScore,
    Value<String>? cryptoSalt,
    Value<DateTime>? createdAt,
    Value<String?>? membershipStatus,
    Value<String?>? membershipPlanName,
    Value<DateTime?>? membershipEndsAt,
    Value<int>? rowid,
  }) {
    return LocalMembersCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      powerScore: powerScore ?? this.powerScore,
      cryptoSalt: cryptoSalt ?? this.cryptoSalt,
      createdAt: createdAt ?? this.createdAt,
      membershipStatus: membershipStatus ?? this.membershipStatus,
      membershipPlanName: membershipPlanName ?? this.membershipPlanName,
      membershipEndsAt: membershipEndsAt ?? this.membershipEndsAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (powerScore.present) {
      map['power_score'] = Variable<int>(powerScore.value);
    }
    if (cryptoSalt.present) {
      map['crypto_salt'] = Variable<String>(cryptoSalt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (membershipStatus.present) {
      map['membership_status'] = Variable<String>(membershipStatus.value);
    }
    if (membershipPlanName.present) {
      map['membership_plan_name'] = Variable<String>(membershipPlanName.value);
    }
    if (membershipEndsAt.present) {
      map['membership_ends_at'] = Variable<DateTime>(membershipEndsAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalMembersCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('fullName: $fullName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('powerScore: $powerScore, ')
          ..write('cryptoSalt: $cryptoSalt, ')
          ..write('createdAt: $createdAt, ')
          ..write('membershipStatus: $membershipStatus, ')
          ..write('membershipPlanName: $membershipPlanName, ')
          ..write('membershipEndsAt: $membershipEndsAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAttendanceQueueTable extends LocalAttendanceQueue
    with TableInfo<$LocalAttendanceQueueTable, LocalAttendanceQueueItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAttendanceQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _athleteIdMeta = const VerificationMeta(
    'athleteId',
  );
  @override
  late final GeneratedColumn<String> athleteId = GeneratedColumn<String>(
    'athlete_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkedInAtMeta = const VerificationMeta(
    'checkedInAt',
  );
  @override
  late final GeneratedColumn<DateTime> checkedInAt = GeneratedColumn<DateTime>(
    'checked_in_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    athleteId,
    checkedInAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_attendance_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAttendanceQueueItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('athlete_id')) {
      context.handle(
        _athleteIdMeta,
        athleteId.isAcceptableOrUnknown(data['athlete_id']!, _athleteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_athleteIdMeta);
    }
    if (data.containsKey('checked_in_at')) {
      context.handle(
        _checkedInAtMeta,
        checkedInAt.isAcceptableOrUnknown(
          data['checked_in_at']!,
          _checkedInAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checkedInAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAttendanceQueueItem map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAttendanceQueueItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      athleteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}athlete_id'],
      )!,
      checkedInAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}checked_in_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $LocalAttendanceQueueTable createAlias(String alias) {
    return $LocalAttendanceQueueTable(attachedDatabase, alias);
  }
}

class LocalAttendanceQueueItem extends DataClass
    implements Insertable<LocalAttendanceQueueItem> {
  final String id;
  final String tenantId;
  final String athleteId;
  final DateTime checkedInAt;
  final bool isSynced;
  const LocalAttendanceQueueItem({
    required this.id,
    required this.tenantId,
    required this.athleteId,
    required this.checkedInAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['athlete_id'] = Variable<String>(athleteId);
    map['checked_in_at'] = Variable<DateTime>(checkedInAt);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  LocalAttendanceQueueCompanion toCompanion(bool nullToAbsent) {
    return LocalAttendanceQueueCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      athleteId: Value(athleteId),
      checkedInAt: Value(checkedInAt),
      isSynced: Value(isSynced),
    );
  }

  factory LocalAttendanceQueueItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAttendanceQueueItem(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      athleteId: serializer.fromJson<String>(json['athleteId']),
      checkedInAt: serializer.fromJson<DateTime>(json['checkedInAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'athleteId': serializer.toJson<String>(athleteId),
      'checkedInAt': serializer.toJson<DateTime>(checkedInAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  LocalAttendanceQueueItem copyWith({
    String? id,
    String? tenantId,
    String? athleteId,
    DateTime? checkedInAt,
    bool? isSynced,
  }) => LocalAttendanceQueueItem(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    athleteId: athleteId ?? this.athleteId,
    checkedInAt: checkedInAt ?? this.checkedInAt,
    isSynced: isSynced ?? this.isSynced,
  );
  LocalAttendanceQueueItem copyWithCompanion(
    LocalAttendanceQueueCompanion data,
  ) {
    return LocalAttendanceQueueItem(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      athleteId: data.athleteId.present ? data.athleteId.value : this.athleteId,
      checkedInAt: data.checkedInAt.present
          ? data.checkedInAt.value
          : this.checkedInAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAttendanceQueueItem(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('athleteId: $athleteId, ')
          ..write('checkedInAt: $checkedInAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, tenantId, athleteId, checkedInAt, isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAttendanceQueueItem &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.athleteId == this.athleteId &&
          other.checkedInAt == this.checkedInAt &&
          other.isSynced == this.isSynced);
}

class LocalAttendanceQueueCompanion
    extends UpdateCompanion<LocalAttendanceQueueItem> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> athleteId;
  final Value<DateTime> checkedInAt;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const LocalAttendanceQueueCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.athleteId = const Value.absent(),
    this.checkedInAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAttendanceQueueCompanion.insert({
    required String id,
    required String tenantId,
    required String athleteId,
    required DateTime checkedInAt,
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       athleteId = Value(athleteId),
       checkedInAt = Value(checkedInAt);
  static Insertable<LocalAttendanceQueueItem> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? athleteId,
    Expression<DateTime>? checkedInAt,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (athleteId != null) 'athlete_id': athleteId,
      if (checkedInAt != null) 'checked_in_at': checkedInAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAttendanceQueueCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? athleteId,
    Value<DateTime>? checkedInAt,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return LocalAttendanceQueueCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      athleteId: athleteId ?? this.athleteId,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (athleteId.present) {
      map['athlete_id'] = Variable<String>(athleteId.value);
    }
    if (checkedInAt.present) {
      map['checked_in_at'] = Variable<DateTime>(checkedInAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAttendanceQueueCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('athleteId: $athleteId, ')
          ..write('checkedInAt: $checkedInAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalGymCacheTable extends LocalGymCache
    with TableInfo<$LocalGymCacheTable, LocalGymCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalGymCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 255,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentOccupancyMeta = const VerificationMeta(
    'currentOccupancy',
  );
  @override
  late final GeneratedColumn<int> currentOccupancy = GeneratedColumn<int>(
    'current_occupancy',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _capacityLimitMeta = const VerificationMeta(
    'capacityLimit',
  );
  @override
  late final GeneratedColumn<int> capacityLimit = GeneratedColumn<int>(
    'capacity_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    tenantId,
    name,
    currentOccupancy,
    capacityLimit,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_gym_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalGymCacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('current_occupancy')) {
      context.handle(
        _currentOccupancyMeta,
        currentOccupancy.isAcceptableOrUnknown(
          data['current_occupancy']!,
          _currentOccupancyMeta,
        ),
      );
    }
    if (data.containsKey('capacity_limit')) {
      context.handle(
        _capacityLimitMeta,
        capacityLimit.isAcceptableOrUnknown(
          data['capacity_limit']!,
          _capacityLimitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_capacityLimitMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tenantId};
  @override
  LocalGymCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalGymCacheEntry(
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      currentOccupancy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_occupancy'],
      )!,
      capacityLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}capacity_limit'],
      )!,
    );
  }

  @override
  $LocalGymCacheTable createAlias(String alias) {
    return $LocalGymCacheTable(attachedDatabase, alias);
  }
}

class LocalGymCacheEntry extends DataClass
    implements Insertable<LocalGymCacheEntry> {
  final String tenantId;
  final String name;
  final int currentOccupancy;
  final int capacityLimit;
  const LocalGymCacheEntry({
    required this.tenantId,
    required this.name,
    required this.currentOccupancy,
    required this.capacityLimit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tenant_id'] = Variable<String>(tenantId);
    map['name'] = Variable<String>(name);
    map['current_occupancy'] = Variable<int>(currentOccupancy);
    map['capacity_limit'] = Variable<int>(capacityLimit);
    return map;
  }

  LocalGymCacheCompanion toCompanion(bool nullToAbsent) {
    return LocalGymCacheCompanion(
      tenantId: Value(tenantId),
      name: Value(name),
      currentOccupancy: Value(currentOccupancy),
      capacityLimit: Value(capacityLimit),
    );
  }

  factory LocalGymCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalGymCacheEntry(
      tenantId: serializer.fromJson<String>(json['tenantId']),
      name: serializer.fromJson<String>(json['name']),
      currentOccupancy: serializer.fromJson<int>(json['currentOccupancy']),
      capacityLimit: serializer.fromJson<int>(json['capacityLimit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tenantId': serializer.toJson<String>(tenantId),
      'name': serializer.toJson<String>(name),
      'currentOccupancy': serializer.toJson<int>(currentOccupancy),
      'capacityLimit': serializer.toJson<int>(capacityLimit),
    };
  }

  LocalGymCacheEntry copyWith({
    String? tenantId,
    String? name,
    int? currentOccupancy,
    int? capacityLimit,
  }) => LocalGymCacheEntry(
    tenantId: tenantId ?? this.tenantId,
    name: name ?? this.name,
    currentOccupancy: currentOccupancy ?? this.currentOccupancy,
    capacityLimit: capacityLimit ?? this.capacityLimit,
  );
  LocalGymCacheEntry copyWithCompanion(LocalGymCacheCompanion data) {
    return LocalGymCacheEntry(
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      name: data.name.present ? data.name.value : this.name,
      currentOccupancy: data.currentOccupancy.present
          ? data.currentOccupancy.value
          : this.currentOccupancy,
      capacityLimit: data.capacityLimit.present
          ? data.capacityLimit.value
          : this.capacityLimit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalGymCacheEntry(')
          ..write('tenantId: $tenantId, ')
          ..write('name: $name, ')
          ..write('currentOccupancy: $currentOccupancy, ')
          ..write('capacityLimit: $capacityLimit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(tenantId, name, currentOccupancy, capacityLimit);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalGymCacheEntry &&
          other.tenantId == this.tenantId &&
          other.name == this.name &&
          other.currentOccupancy == this.currentOccupancy &&
          other.capacityLimit == this.capacityLimit);
}

class LocalGymCacheCompanion extends UpdateCompanion<LocalGymCacheEntry> {
  final Value<String> tenantId;
  final Value<String> name;
  final Value<int> currentOccupancy;
  final Value<int> capacityLimit;
  final Value<int> rowid;
  const LocalGymCacheCompanion({
    this.tenantId = const Value.absent(),
    this.name = const Value.absent(),
    this.currentOccupancy = const Value.absent(),
    this.capacityLimit = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalGymCacheCompanion.insert({
    required String tenantId,
    required String name,
    this.currentOccupancy = const Value.absent(),
    required int capacityLimit,
    this.rowid = const Value.absent(),
  }) : tenantId = Value(tenantId),
       name = Value(name),
       capacityLimit = Value(capacityLimit);
  static Insertable<LocalGymCacheEntry> custom({
    Expression<String>? tenantId,
    Expression<String>? name,
    Expression<int>? currentOccupancy,
    Expression<int>? capacityLimit,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tenantId != null) 'tenant_id': tenantId,
      if (name != null) 'name': name,
      if (currentOccupancy != null) 'current_occupancy': currentOccupancy,
      if (capacityLimit != null) 'capacity_limit': capacityLimit,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalGymCacheCompanion copyWith({
    Value<String>? tenantId,
    Value<String>? name,
    Value<int>? currentOccupancy,
    Value<int>? capacityLimit,
    Value<int>? rowid,
  }) {
    return LocalGymCacheCompanion(
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      currentOccupancy: currentOccupancy ?? this.currentOccupancy,
      capacityLimit: capacityLimit ?? this.capacityLimit,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (currentOccupancy.present) {
      map['current_occupancy'] = Variable<int>(currentOccupancy.value);
    }
    if (capacityLimit.present) {
      map['capacity_limit'] = Variable<int>(capacityLimit.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalGymCacheCompanion(')
          ..write('tenantId: $tenantId, ')
          ..write('name: $name, ')
          ..write('currentOccupancy: $currentOccupancy, ')
          ..write('capacityLimit: $capacityLimit, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalMembersTable localMembers = $LocalMembersTable(this);
  late final $LocalAttendanceQueueTable localAttendanceQueue =
      $LocalAttendanceQueueTable(this);
  late final $LocalGymCacheTable localGymCache = $LocalGymCacheTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localMembers,
    localAttendanceQueue,
    localGymCache,
  ];
}

typedef $$LocalMembersTableCreateCompanionBuilder =
    LocalMembersCompanion Function({
      required String id,
      required String tenantId,
      required String fullName,
      Value<String?> avatarUrl,
      Value<int> powerScore,
      required String cryptoSalt,
      required DateTime createdAt,
      Value<String?> membershipStatus,
      Value<String?> membershipPlanName,
      Value<DateTime?> membershipEndsAt,
      Value<int> rowid,
    });
typedef $$LocalMembersTableUpdateCompanionBuilder =
    LocalMembersCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> fullName,
      Value<String?> avatarUrl,
      Value<int> powerScore,
      Value<String> cryptoSalt,
      Value<DateTime> createdAt,
      Value<String?> membershipStatus,
      Value<String?> membershipPlanName,
      Value<DateTime?> membershipEndsAt,
      Value<int> rowid,
    });

class $$LocalMembersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalMembersTable> {
  $$LocalMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get powerScore => $composableBuilder(
    column: $table.powerScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cryptoSalt => $composableBuilder(
    column: $table.cryptoSalt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get membershipStatus => $composableBuilder(
    column: $table.membershipStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get membershipPlanName => $composableBuilder(
    column: $table.membershipPlanName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get membershipEndsAt => $composableBuilder(
    column: $table.membershipEndsAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalMembersTable> {
  $$LocalMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get powerScore => $composableBuilder(
    column: $table.powerScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cryptoSalt => $composableBuilder(
    column: $table.cryptoSalt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get membershipStatus => $composableBuilder(
    column: $table.membershipStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get membershipPlanName => $composableBuilder(
    column: $table.membershipPlanName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get membershipEndsAt => $composableBuilder(
    column: $table.membershipEndsAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalMembersTable> {
  $$LocalMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<int> get powerScore => $composableBuilder(
    column: $table.powerScore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cryptoSalt => $composableBuilder(
    column: $table.cryptoSalt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get membershipStatus => $composableBuilder(
    column: $table.membershipStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get membershipPlanName => $composableBuilder(
    column: $table.membershipPlanName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get membershipEndsAt => $composableBuilder(
    column: $table.membershipEndsAt,
    builder: (column) => column,
  );
}

class $$LocalMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalMembersTable,
          LocalMember,
          $$LocalMembersTableFilterComposer,
          $$LocalMembersTableOrderingComposer,
          $$LocalMembersTableAnnotationComposer,
          $$LocalMembersTableCreateCompanionBuilder,
          $$LocalMembersTableUpdateCompanionBuilder,
          (
            LocalMember,
            BaseReferences<_$AppDatabase, $LocalMembersTable, LocalMember>,
          ),
          LocalMember,
          PrefetchHooks Function()
        > {
  $$LocalMembersTableTableManager(_$AppDatabase db, $LocalMembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<int> powerScore = const Value.absent(),
                Value<String> cryptoSalt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> membershipStatus = const Value.absent(),
                Value<String?> membershipPlanName = const Value.absent(),
                Value<DateTime?> membershipEndsAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalMembersCompanion(
                id: id,
                tenantId: tenantId,
                fullName: fullName,
                avatarUrl: avatarUrl,
                powerScore: powerScore,
                cryptoSalt: cryptoSalt,
                createdAt: createdAt,
                membershipStatus: membershipStatus,
                membershipPlanName: membershipPlanName,
                membershipEndsAt: membershipEndsAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String fullName,
                Value<String?> avatarUrl = const Value.absent(),
                Value<int> powerScore = const Value.absent(),
                required String cryptoSalt,
                required DateTime createdAt,
                Value<String?> membershipStatus = const Value.absent(),
                Value<String?> membershipPlanName = const Value.absent(),
                Value<DateTime?> membershipEndsAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalMembersCompanion.insert(
                id: id,
                tenantId: tenantId,
                fullName: fullName,
                avatarUrl: avatarUrl,
                powerScore: powerScore,
                cryptoSalt: cryptoSalt,
                createdAt: createdAt,
                membershipStatus: membershipStatus,
                membershipPlanName: membershipPlanName,
                membershipEndsAt: membershipEndsAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalMembersTable,
      LocalMember,
      $$LocalMembersTableFilterComposer,
      $$LocalMembersTableOrderingComposer,
      $$LocalMembersTableAnnotationComposer,
      $$LocalMembersTableCreateCompanionBuilder,
      $$LocalMembersTableUpdateCompanionBuilder,
      (
        LocalMember,
        BaseReferences<_$AppDatabase, $LocalMembersTable, LocalMember>,
      ),
      LocalMember,
      PrefetchHooks Function()
    >;
typedef $$LocalAttendanceQueueTableCreateCompanionBuilder =
    LocalAttendanceQueueCompanion Function({
      required String id,
      required String tenantId,
      required String athleteId,
      required DateTime checkedInAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$LocalAttendanceQueueTableUpdateCompanionBuilder =
    LocalAttendanceQueueCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> athleteId,
      Value<DateTime> checkedInAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });

class $$LocalAttendanceQueueTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAttendanceQueueTable> {
  $$LocalAttendanceQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get athleteId => $composableBuilder(
    column: $table.athleteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkedInAt => $composableBuilder(
    column: $table.checkedInAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAttendanceQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAttendanceQueueTable> {
  $$LocalAttendanceQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get athleteId => $composableBuilder(
    column: $table.athleteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkedInAt => $composableBuilder(
    column: $table.checkedInAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAttendanceQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAttendanceQueueTable> {
  $$LocalAttendanceQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get athleteId =>
      $composableBuilder(column: $table.athleteId, builder: (column) => column);

  GeneratedColumn<DateTime> get checkedInAt => $composableBuilder(
    column: $table.checkedInAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$LocalAttendanceQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAttendanceQueueTable,
          LocalAttendanceQueueItem,
          $$LocalAttendanceQueueTableFilterComposer,
          $$LocalAttendanceQueueTableOrderingComposer,
          $$LocalAttendanceQueueTableAnnotationComposer,
          $$LocalAttendanceQueueTableCreateCompanionBuilder,
          $$LocalAttendanceQueueTableUpdateCompanionBuilder,
          (
            LocalAttendanceQueueItem,
            BaseReferences<
              _$AppDatabase,
              $LocalAttendanceQueueTable,
              LocalAttendanceQueueItem
            >,
          ),
          LocalAttendanceQueueItem,
          PrefetchHooks Function()
        > {
  $$LocalAttendanceQueueTableTableManager(
    _$AppDatabase db,
    $LocalAttendanceQueueTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAttendanceQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAttendanceQueueTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalAttendanceQueueTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> athleteId = const Value.absent(),
                Value<DateTime> checkedInAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAttendanceQueueCompanion(
                id: id,
                tenantId: tenantId,
                athleteId: athleteId,
                checkedInAt: checkedInAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String athleteId,
                required DateTime checkedInAt,
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAttendanceQueueCompanion.insert(
                id: id,
                tenantId: tenantId,
                athleteId: athleteId,
                checkedInAt: checkedInAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAttendanceQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAttendanceQueueTable,
      LocalAttendanceQueueItem,
      $$LocalAttendanceQueueTableFilterComposer,
      $$LocalAttendanceQueueTableOrderingComposer,
      $$LocalAttendanceQueueTableAnnotationComposer,
      $$LocalAttendanceQueueTableCreateCompanionBuilder,
      $$LocalAttendanceQueueTableUpdateCompanionBuilder,
      (
        LocalAttendanceQueueItem,
        BaseReferences<
          _$AppDatabase,
          $LocalAttendanceQueueTable,
          LocalAttendanceQueueItem
        >,
      ),
      LocalAttendanceQueueItem,
      PrefetchHooks Function()
    >;
typedef $$LocalGymCacheTableCreateCompanionBuilder =
    LocalGymCacheCompanion Function({
      required String tenantId,
      required String name,
      Value<int> currentOccupancy,
      required int capacityLimit,
      Value<int> rowid,
    });
typedef $$LocalGymCacheTableUpdateCompanionBuilder =
    LocalGymCacheCompanion Function({
      Value<String> tenantId,
      Value<String> name,
      Value<int> currentOccupancy,
      Value<int> capacityLimit,
      Value<int> rowid,
    });

class $$LocalGymCacheTableFilterComposer
    extends Composer<_$AppDatabase, $LocalGymCacheTable> {
  $$LocalGymCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentOccupancy => $composableBuilder(
    column: $table.currentOccupancy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capacityLimit => $composableBuilder(
    column: $table.capacityLimit,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalGymCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalGymCacheTable> {
  $$LocalGymCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentOccupancy => $composableBuilder(
    column: $table.currentOccupancy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capacityLimit => $composableBuilder(
    column: $table.capacityLimit,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalGymCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalGymCacheTable> {
  $$LocalGymCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get currentOccupancy => $composableBuilder(
    column: $table.currentOccupancy,
    builder: (column) => column,
  );

  GeneratedColumn<int> get capacityLimit => $composableBuilder(
    column: $table.capacityLimit,
    builder: (column) => column,
  );
}

class $$LocalGymCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalGymCacheTable,
          LocalGymCacheEntry,
          $$LocalGymCacheTableFilterComposer,
          $$LocalGymCacheTableOrderingComposer,
          $$LocalGymCacheTableAnnotationComposer,
          $$LocalGymCacheTableCreateCompanionBuilder,
          $$LocalGymCacheTableUpdateCompanionBuilder,
          (
            LocalGymCacheEntry,
            BaseReferences<
              _$AppDatabase,
              $LocalGymCacheTable,
              LocalGymCacheEntry
            >,
          ),
          LocalGymCacheEntry,
          PrefetchHooks Function()
        > {
  $$LocalGymCacheTableTableManager(_$AppDatabase db, $LocalGymCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalGymCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalGymCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalGymCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> tenantId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> currentOccupancy = const Value.absent(),
                Value<int> capacityLimit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalGymCacheCompanion(
                tenantId: tenantId,
                name: name,
                currentOccupancy: currentOccupancy,
                capacityLimit: capacityLimit,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tenantId,
                required String name,
                Value<int> currentOccupancy = const Value.absent(),
                required int capacityLimit,
                Value<int> rowid = const Value.absent(),
              }) => LocalGymCacheCompanion.insert(
                tenantId: tenantId,
                name: name,
                currentOccupancy: currentOccupancy,
                capacityLimit: capacityLimit,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalGymCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalGymCacheTable,
      LocalGymCacheEntry,
      $$LocalGymCacheTableFilterComposer,
      $$LocalGymCacheTableOrderingComposer,
      $$LocalGymCacheTableAnnotationComposer,
      $$LocalGymCacheTableCreateCompanionBuilder,
      $$LocalGymCacheTableUpdateCompanionBuilder,
      (
        LocalGymCacheEntry,
        BaseReferences<_$AppDatabase, $LocalGymCacheTable, LocalGymCacheEntry>,
      ),
      LocalGymCacheEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalMembersTableTableManager get localMembers =>
      $$LocalMembersTableTableManager(_db, _db.localMembers);
  $$LocalAttendanceQueueTableTableManager get localAttendanceQueue =>
      $$LocalAttendanceQueueTableTableManager(_db, _db.localAttendanceQueue);
  $$LocalGymCacheTableTableManager get localGymCache =>
      $$LocalGymCacheTableTableManager(_db, _db.localGymCache);
}
