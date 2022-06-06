// standard node module
const execFile = require('child_process').execFile
const fs = require("fs");
const { respond } = require('./response');

const filePath = "./opencv/build/kt.jpg";

var count = 0;

exports.analyze = function (req, res, next) {

    if (req.body.image == null) {
        console.log("No image in body");
        respond(req, res, { success: false, message: "No image in body", data: null });
        return;
    }
    if (!req.body.image.includes("data:image\/jpg;base64,")) {
        console.log("image not in correct format")
        respond(req, res, { success: false, message: "Image not in correct format.  Could not make jpeg.  Missing " + "data:image\/jpg;base64,", data: null });
        return;
    }
    var img = req.body.image.replace(/^data:image\/jpg;base64,/, "");

    // console.log("img data");
    // console.log(img);

    if (req.body.numberOfDrops == null) {
        console.log("No numberOfDrops in body");
        respond(req, res, { success: false, message: "No numberOfDrops in body", data: null });
        return;
    }
    var numberOfDrops = req.body.numberOfDrops;

    // console.log(req.body);

    var realFile = Buffer.from(img, "base64");

    if (realFile.length == 0) {
        console.log("realFile.length == 0");
        respond(req, res, { success: false, message: null, data: null });
        return;
    }

    fs.writeFile(filePath, realFile, function (err) {
        if (err) {
            console.log("err = " + err);
            respond(req, res, { success: false, message: err, data: null });
            return;
        }

        // this launches the executable and returns immediately
        var child = execFile("./opencv/build/ktImg", [filePath, numberOfDrops], function (error, stdout, stderr) {
            // This callback is invoked once the child terminates
            // You'd want to check err/stderr as well!
            console.log("Here is the complete output of the program: ");
            console.log("STDOUT: " + stdout)
            console.log("STDERR: " + stderr);
            console.log("ERROR: " + error);

            fs.createReadStream(filePath).pipe(fs.createWriteStream("./opencv/build/kt" + count + ".jpg"));
            count = count + 1;
            // try {
            //     fs.unlinkSync(filePath);
            // }
            // catch (e) {
            //     console.log(e);
            // }

            // this means that the image was malformed
            if (error != null) {
                console.log("error = " + error);
                respond(req, res, { success: false, message: error + stdout + stderr, data: null });
                return;
            }

            var sample;

            try {
                var find = '-nan';
                var re = new RegExp(find, 'g');
                sample = JSON.parse(stdout.replace(re, '"***NaN***"'));
            } catch (e) {
                respond(req, res, { success: false, message: "Could not determine analysis program output - server error.  Contact brady@microbiometer.com", data: null });
                return; // error in the above string (in this case, yes)!
            }

            // error checking and feedback
            if (sample.result == -1) {
                respond(req, res, { success: false, message: "Could not analyze sample, server program failure.  Contact brady@microbiometer.com", data: null });
                return;
            }
            if (sample.result == -101) {
                respond(req, res, { success: false, message: "Could not analyze sample because couldn't detect the appropriate features. Perhaps image sent was too cropped and feature detection failed?", data: null });
                return;
            }
            if (sample.result == -104) {
                respond(req, res, { success: false, message: "Could not analyze sample, not enough dynamic range in image.  Colors are compressed to a small range, much less than 0-255.  This could be the result of a dirty or smudged camera lens.  Please clean the lens thoroughly and try again.", data: null });
                return;
            }
            if (sample.result == -105) {
                respond(req, res, { success: false, message: "Could not analyze sample, not enough dynamic range in image.  Reasons could be the testcard is too close to the camera, or the lens is smudged. Image the card so that it takes up about 2-3 cm of the middle of the camera screen. Please clean the lens thoroughly and try again.", data: null });
                return;
            }

            sample.sampleId = req.body.sampleId;
            sample.numberOfDrops = numberOfDrops;
            sample.date = new Date();
            var data = {};
            console.log(sample);

            const db = req.app.locals.mongoDB;

            db.collection("ktSamples").insertOne(sample, (err, result) => {
                if (err) {
                    respond(req, res, { success: false, message: err });
                    return;
                }
                data.sampleId = req.body.sampleId;
                data.numberOfDrops = numberOfDrops;
                data.MBC = sample.MBC;
                data.F2B = sample.F2B;
                data.percentFungal = sample.percentFungal;
                data.percentBacterial = sample.percentBacterial;

                respond(req, res, { success: true, message: "Here's your reading for " + req.body.sampleId, data: data });
            });
        });
    });


}