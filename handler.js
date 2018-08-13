const got = require('got');
const cheerio = require('cheerio');
const dynamoose = require('dynamoose');
const moment = require('moment');
const AWS = require('aws-sdk');
const fs = require('fs');
const s3 = new AWS.S3();
const BUCKET_NAME = "amathon-novemberde";

AWS.config.region = "ap-northeast-2";

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

const uploadS3 = (buffer, path) => {
	const params = {
		Bucket: BUCKET_NAME,// s3 버킷 이름
		Key: path,// s3 경로
		Body: buffer,// 파일 내용
		ContentLength: buffer.length,// 파일 크기
		ContentType: "application/json"// mimetype
	};

	return new Promise((resolve, reject) => {
		return s3.putObject(params, (err, data) => {
			if (err) return reject(err);
			return resolve(data);
		})
	});
}

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
			return i === 0;
		}).find('.ah_item').each(((i, el) => {
			if (i >= 20) return;
			const keyword = $naver(el).find('.ah_k').text();
			naverKeywords[`rank${i}`] = keyword;
			// naverKeywords.push({rank, keyword});
		}));
		$daum('.rank_cont').find('.link_issue[tabindex=-1]').each((i, el) => {
			const keyword = $daum(el).text();
			daumKeywords[`rank${i}`] = keyword;
			// daumKeywords.push({rank: i+1, keyword});
		});

		// console.log({
		// 	naver: naverKeywords,
		// 	daum: daumKeywords,
		// });

		const randomizedPrefix = Math.random().toString(36).substring(2, 6);
		const now = moment();
		const naverFilePath = `${now.get("year")}/${now.get("month")+1}/${now.get("date")}/naver/${randomizedPrefix}${now.toISOString()}`;
		const daumFilePath = `${now.get("year")}/${now.get("month")+1}/${now.get("date")}/daum/${randomizedPrefix}${now.toISOString()}`;
		const naverBuffer = Buffer.from(JSON.stringify({
			...naverKeywords,
			portal: 'naver',
			createdAt,
		}));
		const daumBuffer = Buffer.from(JSON.stringify({
			...daumKeywords,
			portal: 'daum',
			createdAt,
		}));

		await uploadS3(naverBuffer, naverFilePath);
		await uploadS3(daumBuffer, daumFilePath);

		return callback(null, "success");
	} catch (err) {
		callback(err);
	}
}