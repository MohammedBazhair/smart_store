class ProductQueryBuilder {
  ProductQueryBuilder._();

  /// sp  -> store_products,
  /// gb  -> global_produucts,
  /// c   -> category
  static const storeProductColumnsAndJoins = '''
      sp.store_id       AS store_id,
      sp.product_id     AS product_id,
      sp.price          AS price,
      sp.quantity       AS quantity,
      sp.expiry_date    AS expiry_date,
      sp.notes          AS notes,
      sp.updated_at     AS updated_at,
      sp.is_deleted     AS is_deleted,

      gp.id             AS global_product_id,
      gp.name           AS product_name,
      gp.category_id    AS category_id,
      gp.barcode        AS barcode,
      gp.created_at     AS product_created_at,
      gp.updated_at     AS product_updated_at,
      gp.is_deleted     AS product_is_deleted,

      c.category_id     AS category_id,
      c.category_name   AS category_name,
      c.updated_at      AS category_updated_at

    FROM store_products sp
    LEFT JOIN global_products gp ON sp.product_id = gp.id
    LEFT JOIN categories c ON gp.category_id = c.category_id
''';
}
