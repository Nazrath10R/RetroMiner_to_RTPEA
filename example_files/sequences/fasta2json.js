var fasta2json = require("fasta2json");
var fs = require("fs");
var files = fs.readdirSync('./');


var a = []; // Create a new empty array.

for (var i = 0; i < files.length; i++) {
    // Iterate over numeric indexes from 0 to 5, as everyone expects.
    console.log(files[i]);
    var json = fasta2json.ReadFasta(files[i]);

    fs.writeFile("./json/"+files[i].slice(0,-6)+".json", JSON.stringify(json), (err) => {
        if (err) {
            console.error(err);
            return;
        };
        // console.log("File has been created");
    });

}


// console.log(json)

// json = fasta2json.ParseFasta(json)
// fasta2json.Export(json, "file.json");
