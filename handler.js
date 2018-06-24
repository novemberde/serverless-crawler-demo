const got = require('got');
const cheerio = require('cheerio');
const dynamoose = require('dynamoose');

require('aws-sdk').config.region = "ap-northeast-2";

const PortalKeyword = dynamoose.model('PortalKeyword', {
    portal: {
        type: String,
        hashKey: true
    },
    createdAt: {
        type: String,
        rangeKey: true
    },
	keywords: {
		type: Array
	}
}, {
    create: false, // Create a table if not exist,
});

exports.crawler = async function (event, context, callback) {
	try {
		let naverKeywords = [];
		let daumKeywords = [];

		const result = await Promise.all([
			got('https://naver.com'),
			got('http://daum.net'),
		]);
		const createdAt = new Date().toISOString();
		
		const naverContent = result[0].body;
		const daumContent = result[1].body;
		const $naver = cheerio.load(naverContent);
		const $daum = cheerio.load(daumContent);

		// Get doms containing latest keywords
		$naver('.ah_l').filter((i, el) => {
			return i===0;
		}).find('.ah_item').each(((i, el) => {
			if(i >= 20) return;
			const keyword = $naver(el).find('.ah_k').text();
			naverKeywords.push({rank: i+1, keyword});
		}));
		$daum('.rank_cont').find('.link_issue[tabindex=-1]').each((i, el) => {
			const keyword = $daum(el).text();
			daumKeywords.push({rank: i+1, keyword});
		});

		// console.log({
		// 	naver: naverKeywords,
		// 	daum: daumKeywords,
		// });

		await new PortalKeyword({
			portal: 'naver',
			createdAt,
			keywords: naverKeywords
		}).save();
		await new PortalKeyword({
			portal: 'daum',
			createdAt,
			keywords: daumKeywords
		}).save();

		return callback(null, "success");
	} catch (err) {
		callback(err);
	}
}