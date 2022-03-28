/* global beforeAll, afterAll, test, expect */
require('regenerator-runtime');

const db = require('../../src/server/db');

const {queryNematodeConnections, mergeGapJunctions} = require('../../src/server/db/nematode-connections');

const fixture1 = require('./nematode-connections-1.json');
const fixture2 = require('./nematode-connections-2.json');
const fixture3 = require('./nematode-connections-3.json');

let connection;

beforeAll(() => {
  return db.connect({ useTestDatabase: true }).then( c => {
    connection = c;
    return connection;
  });
});

afterAll(() => {
   return connection.end();
});

test('merge gap junctions with flipped pre/post partners', function(){
  const inputGapJunctions = [
    {
      pre: 'AIAR',
      post: 'ASIR',
      type: 'electrical',
      annotations: [],
      synapses: {
        'dataset1': 5,
        'dataset2': 9
      }
    },
    {
      pre: 'ASIR',
      post: 'AIAR',
      type: 'electrical',
      annotations: [],
      synapses: {
        'dataset0': 20
      }
    },
    {
      pre: 'ASER',
      post: 'AWAR',
      type: 'electrical',
      annotations: [],
      synapses: {
        'dataset4': 1
      }
    }
  ];

  const mergedGapJunctions = mergeGapJunctions(inputGapJunctions);
  expect(mergedGapJunctions.length).toEqual(2);
  expect(mergedGapJunctions[0].synapses).toEqual({
    dataset0: 20,
    dataset1: 5,
    dataset2: 9
  });

  expect(mergedGapJunctions[1].synapses).toEqual({
    dataset4: 1
  });


});

test('get no connections when cells option is empty', function(){
  let expected = [];

  let opts = {
    cells: [],
    "datasetType": "head",
    "datasetIds": [
      "SEM_adult", "SEM_L1_2", "SEM_L1_3", "SEM_L1_4", "SEM_L2_2", "TEM_adult", "TEM_L1_5", "TEM_L3", "white_ad", "white_l4"
    ],
    "thresholdChemical": 3,
    "thresholdElectrical": 2,
    "thresholdFunctional": 4,
    "includeNeighboringCells": true,
    "includeAnnotations": true
  };

  return expect(queryNematodeConnections( connection, opts )).resolves.toEqual(expected);
});

test('returns no annotations when includeAnnotations is set to false', function(){
  let opts = {
    cells: [],
    "datasetType": "head",
    "datasetIds": [ "SEM_adult", "SEM_L1_2", "SEM_L1_3", "SEM_L1_4", "SEM_L2_2", "TEM_adult", "TEM_L1_5", "TEM_L3", "white_ad", "white_l4"],
    "thresholdChemical": 3,
    "thresholdElectrical": 2,
    "thresholdFunctional": 4,
    "includeNeighboringCells": true,
    "includeAnnotations": false
  };

  return queryNematodeConnections( connection, opts ).then( res => {
    res.forEach( connection => {
      expect(connection.annotations).toEqual( [] );
    });
  });
});