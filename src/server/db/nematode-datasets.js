let queryDatasets = async connection => {
  const datasetsSql = `
    SELECT id, collection, name, description, time, visual_time, datatypes
    FROM datasets
    ORDER BY id
  `;
  const [rows, ] = await connection.query(datasetsSql);

  return rows;
};

module.exports = queryDatasets;
