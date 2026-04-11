enum FilterOperator {
  equal('='),
  notEqual('!='),
  greaterThan('>'),
  lessThan('<'),
  greaterOrEqual('>='),
  lessOrEqual('<='),
  like('LIKE');

  const FilterOperator(this.symbol);
  final String symbol;
}

enum FilterJoiner {
  or('OR'),
  and('AND');

  const FilterJoiner(this.sql);

  final String sql;
}

class Filter {
  const Filter({
    required this.column,
    this.operator = FilterOperator.equal,
    required this.value,
  });
  final String column;
  final FilterOperator operator;
  final Object value;

  String get toSql => '$column ${operator.symbol} ?';
}

class FilterGroup {
  const FilterGroup({
    required this.filters,
    this.joiner = FilterJoiner.and,
  });

  final List<Filter> filters;
  final FilterJoiner joiner;

  String get toSql {
    if (filters.isEmpty) return '';
    return '(${filters.map((f) => f.toSql).join(' ${joiner.sql} ')})';
  }

  List<Object?> get values => filters.map((f) => f.value).toList();
}

class WhereQueryParams {
  const WhereQueryParams({
    this.groups,
    this.groupJoiner = FilterJoiner.and,
  });
  final List<FilterGroup>? groups;
  final FilterJoiner groupJoiner;
}

class WhereQueryBuilder {
  static ({String? where, List<Object?>? whereArgs}) build(
    WhereQueryParams? params,
  ) {
    const empty = (where: null, whereArgs: null);
    if (params == null) return empty;
    final groups = params.groups;
    final groupJoiner = params.groupJoiner;
    if (groups == null || groups.isEmpty) return empty;

    final where = StringBuffer();
    final args = <Object?>[];

    for (int i = 0; i < groups.length; i++) {
      final group = groups[i];

      where.write(group.toSql);

      args.addAll(group.values);

      if (i < groups.length - 1) {
        where.write(' ${groupJoiner.sql} ');
      }
    }

    return (where: where.toString(), whereArgs: args);
  }
}
