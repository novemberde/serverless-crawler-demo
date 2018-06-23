// Cause unhandled promise error.
// exports.crawler = async function (event, context, callback) {
// 	throw new Error("Error from Hello world!");
// }

exports.crawler = async function (event, context, callback) {
	try {
		throw new Error("Error from trycatch")	
	} catch (err) {
		callback(err);
	}
}