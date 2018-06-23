const crawler = require('./handler').crawler;

crawler({}, {}, (err, result) => {
    if(err) return console.error(err);
    console.log(result);
});