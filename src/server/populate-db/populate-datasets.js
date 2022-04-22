let populateDatasets = async (connection, datasets) => {
  const TABLE = 'datasets';
  const TABLE_FIELDS = [
    'id',
    'collection',
    'name',
    'description',
    'time',
    'visual_time',
    'datatypes'
  ];

  let values = datasets.map(dataset => {
    let { id, type, name, description, time, visualTime, datatypes } = dataset;
    return [id, type, name, description, time, visualTime, datatypes];
  });

  await connection.query(
    `INSERT INTO ${TABLE} ( ${TABLE_FIELDS.join(', ')} ) VALUES ?`,
    [values]
  );
};

module.exports = {
  populateDatasets
};
