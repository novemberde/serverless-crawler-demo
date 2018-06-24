// Use puppeteer. This is too big size package to apply on AWS Lambda
const puppeteer = require('puppeteer');
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
		let nateKeywords = [];

		const browser = await puppeteer.launch();
		const naverPage = await browser.newPage();
		const daumPage = await browser.newPage();
		const natePage = await browser.newPage();

		await Promise.all([
			naverPage.goto('https://naver.com'),
			daumPage.goto('http://daum.net'),
			natePage.goto('http://nate.com')
		]);

		const createdAt = new Date().toISOString();

		// Ensure that all resources are loaded.
		await Promise.all([
			naverPage.waitFor(1000),
			daumPage.waitFor(1000),
			natePage.waitFor(1000),
		]);
		
		const naverContent = await naverPage.content();
		const daumContent = await daumPage.content();
		const nateContent = await natePage.content();
		
		const $naver = cheerio.load(naverContent);
		const $daum = cheerio.load(daumContent);
		const $nate = cheerio.load(nateContent);

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

		$nate('.kwd_list').filter((i, el) => {
			return i === 0;
		}).find('li').each((i, el) => {
			const keyword = $nate(el).find('a').text();
			nateKeywords.push({rank: i+1, keyword});
		});

		// console.log({
		// 	naver: naverKeywords,
		// 	daum: daumKeywords,
		// 	nate: nateKeywords
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
		await new PortalKeyword({
			portal: 'nate',
			createdAt,
			keywords: nateKeywords
		}).save();

		await browser.close();
	} catch (err) {
		callback(err);
	}
}