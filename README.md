# Serverless Group First Hands-on Part 2

AWSKRUG Serverless Group의 첫번째 핸즈온 Part.2 웹크롤러 만들기입니다.😁

[Part.1](https://github.com/novemberde/serverless-todo-demo)을 하셨다면 "Cloud9 시작하기", "Serverless Framework 소개", 그리고 "S3 bucket 생성하기"는 넘어가도 좋습니다.

## Objective

Amazon Web Service 를 활용하여 Serverless architecture로 웹크롤러를 배포합니다.
크롤링된 데이터는 DynamoDB에 저장합니다.

## AWS Resources

AWS에서 사용하는 리소스는 다음과 같습니다.

- Cloud9: 코드 작성, 실행 및 디버깅을 위한 클라우드 기반 IDE.
- Lambda: 서버를 프로비저닝하거나 관리하지 않고도 코드를 실행할 수 있게 해주는 컴퓨팅 서비스. 서버리스 아키텍쳐의 핵심 서비스.
- DynamoDB: 완벽하게 관리되는 NoSQL 데이터베이스 서비스로, 원활한 확장성과 함께 빠르고 예측 가능한 성능을 제공.

## Cloud 9 시작하기

Cloud9 은 하나의 IDE입니다. 그렇지만 이전의 설치형 IDE와는 다릅니다. 설치형 IDE는 로컬 PC에 프로그램을 설치하던가
실행하는 방식이었다면, Cloud9은 브라우저가 실행가능한 모든 OS에서 사용이 가능합니다.

맨 처음 Cloud9은 AWS 내에서가 아닌 별도의 서비스로 제공되었습니다. AWS에 인수된 이후 Cloud9은 AWS의 Managed Service형태로 바뀌었고,
AWS의 서비스와 결합하여 사용이 가능해졌습니다. 코드 편집과 명령줄 지원 등의 평범한 IDE 기능을 지니고 있던 반면에, 현재는 AWS 서비스와
결합되어 직접 Lambda 코드를 배포하던가, 실제로 Cloud9이 실행되고 있는 EC2의 컴퓨팅 성능을 향상시켜서
로컬 PC의 사양에 종속되지 않은 개발을 할 수가 있습니다.

그러면 Cloud9 환경을 시작해봅시다.

[Cloud 9 Console](https://ap-southeast-1.console.aws.amazon.com/cloud9/home?region=ap-southeast-1#)에 접속합니다.

아래와 같은 화면에서 [Create Environment](https://ap-southeast-1.console.aws.amazon.com/cloud9/home/create) 버튼을 누릅니다.

![c9-create](/images/c9-create.png)

Name과 Description을 다음과 같이 입력합니다.

- Name: ServerlessHandsOn
- Description: Serverless hands-on in AWSKRUG Serverless Group

![c9-create-name](/images/c9-create-name.png)

Configure Setting은 다음과 같이 합니다.

- Environment Type: EC2
- Instance Type: T2.micro
- Cost Save Setting: After 30 minutes
- Network Settings: Default

![c9-conf](/images/c9-conf.png)

모든 설정을 마쳤다면 Cloud9 Environment를 생성하고 Open IDE를 통해 개발 환경에 접속합니다.

접속하면 다음과 같은 화면을 볼 수 있습니다.

1. 현재 Environment name
2. EC2에서 명령어를 입력할 수 있는 Terminal
3. Lambda Functions
    - Local Functions: 배포되지 않은 편집중인 Functions
    - Remote Functions: 현재 설정해놓은 Region에 배포된 Lambda Functions
4. Preferences

![c9-env](/images/c9-env.png)

현재 ap-southeast-1 region에 Cloud9 Environment를 배포했으므로 Default Region이 ap-southeast-1으로 되어 있습니다.
Preferences(설정 화면)에서 ap-northeast-2(Seoul Region)으로 바꾸어줍니다.

- Preferences > AWS Settings > Region > Asia Pacific(Seoul)

![c9-region](/images/c9-region.png)

설정을 마친 다음 Node.js 버전을 올려야합니다.
현재(2018-06-30) 제공하는 node의 버전이 6.10이기 때문입니다.
보통은 nvm을 따로 설치해야하지만 Cloud9을 사용하면 별도의 nvm 설치는 필요없습니다.
다음의 명령어를 terminal에 입력하여 node의 버전을 8.10으로 설정합니다.

```sh
$ sudo yum groupinstall 'Development Tools'
$ nvm install 8.10
Downloading https://nodejs.org/dist/v8.10.0/node-v8.10.0-linux-x64.tar.xz...
######################################################################## 100.0%
Now using node v8.10.0 (npm v5.6.0)

# 8.10을 default로 사용하기
$ nvm alias default 8.10
```

Cloud9 설정을 완료하였습니다.

## [Serverless Framework](https://serverless.com/)

![serverless framework main](/images/serverless-framework-1.png)

Serverless Framework 메인에 나와있는 소개문구는 다음과 같습니다.

Serverless is your toolkit for deploying and operating serverless architectures.
Focus on your application, not your infrastructure.

위 내용을 번역한 내용은 "Serverless는 서버 없는 아키텍처를 배치하고 운영하기 위한 툴킷입니다. 인프라가 아닌 애플리케이션에 집중합니다." 입니다.
이처럼 Serverless framework는 Serverless architecture를 운영하기 위한 툴이라고 생각하면 됩니다.

그러면 serverless framework를 사용하기 위한 환경은 어떻게 될까요?

node.js가 설치되어 있는 환경에서 사용할 수 있습니다.

open source로 기여하고 싶다면 [https://github.com/serverless/serverless](https://github.com/serverless/serverless)에서 issue와 pull request를 등록해주세요.

### Serverless Framework 살펴보기

Serverless Framework를 사용하기 위해서 명령어들을 살펴봅시다.

```sh
# Serverless Framework를 설치합니다.
$ npm i -g serverless

# 명령어들을 확인해봅니다.
$ serverless --help

Commands
* You can run commands with "serverless" or the shortcut "sls"
* Pass "--verbose" to this command to get in-depth plugin info
* Pass "--no-color" to disable CLI colors
* Pass "--help" after any <command> for contextual help

Framework
* Documentation: https://serverless.com/framework/docs/

config ........................ Configure Serverless
config credentials ............ Configures a new provider profile for the Serverless Framework
create ........................ Create new Serverless service
deploy ........................ Deploy a Serverless service
deploy function ............... Deploy a single function from the service
deploy list ................... List deployed version of your Serverless Service
deploy list functions ......... List all the deployed functions and their versions
info .......................... Display information about the service
install ....................... Install a Serverless service from GitHub or a plugin from the Serverless registry
invoke ........................ Invoke a deployed function
invoke local .................. Invoke function locally
logs .......................... Output the logs of a deployed function
metrics ....................... Show metrics for a specific function
package ....................... Packages a Serverless service
plugin ........................ Plugin management for Serverless
plugin install ................ Install and add a plugin to your service
plugin uninstall .............. Uninstall and remove a plugin from your service
plugin list ................... Lists all available plugins
plugin search ................. Search for plugins
print ......................... Print your compiled and resolved config file
remove ........................ Remove Serverless service and all resources
rollback ...................... Rollback the Serverless service to a specific deployment
rollback function ............. Rollback the function to the previous version
slstats ....................... Enable or disable stats

Platform (Beta)
* The Serverless Platform is currently in experimental beta. Follow the docs below to get started.
* Documentation: https://serverless.com/platform/docs/

emit .......................... Emits an event to a running Event Gateway
login ......................... Login or sign up for the Serverless Platform
logout ........................ Logout from the Serverless Platform
run ........................... Runs the Event Gateway and the Emulator

Plugins
AwsConfigCredentials, Config, Create, Deploy, Emit, Info, Install, Invoke, Login, Logout, Logs, Metrics, Package, Plugin, PluginInstall, PluginList, PluginSearch, PluginUninstall, Print, Remove, Rollback, Run, SlStats
```

여기서 자주 사용하게 될 명령어는 다음과 같습니다.

- create: 프로젝트 생성시 사용
- deploy: 배포할 때 사용
- package: 배포될 패키지의 구조를 보고싶을 때 사용
- invoke: 특정 handler를 동작시킬 때 사용
- remove: 배포된 리소스를 제거할 때 사용

간단하게 로컬에서 serverless 명령어를 테스트해봅니다. deploy 명령어는 추후에 사용하겠습니다.

```sh
# Global 로 serverless framework 설치
$ npm i -g serverless

# serverless service 생성 힌트 받기
$ serverless create --help
Plugin: Create
create ........................ Create new Serverless service
    --template / -t .................... Template for the service. Available templates: "aws-nodejs", "aws-nodejs-typescript", "aws-nodejs-ecma-script", "aws-python", "aws-python3", "aws-groovy-gradle", "aws-java-maven", "aws-java-gradle", "aws-kotlin-jvm-maven", "aws-kotlin-jvm-gradle", "aws-kotlin-nodejs-gradle", "aws-scala-sbt", "aws-csharp", "aws-fsharp", "aws-go", "aws-go-dep", "azure-nodejs", "fn-nodejs", "fn-go", "google-nodejs", "kubeless-python", "kubeless-nodejs", "openwhisk-java-maven", "openwhisk-nodejs", "openwhisk-php", "openwhisk-python", "openwhisk-swift", "spotinst-nodejs", "spotinst-python", "spotinst-ruby", "spotinst-java8", "webtasks-nodejs", "plugin" and "hello-world"
    --template-url / -u ................ Template URL for the service. Supports: GitHub, BitBucket
    --template-path .................... Template local path for the service.
    --path / -p ........................ The path where the service should be created (e.g. --path my-service)
    --name / -n ........................ Name for the service. Overwrites the default name of the created service. ## "

# node를 사용하므로 템플릿을 "aws-nodejs" 로 "sample-app" 생성하기
$ serverless create -t "aws-nodejs" -p sample-app

# sample-app에서 명령어 연습하기
$ cd sample-app
~/sample-app $ serverless package
Serverless: Packaging service...
Serverless: Excluding development dependencies...

# 여기까지 진행했다면 .serverless 디렉터리를 확인할 수 있습니다.
~/sample-app $ cd .serverless

# 생성된 파일을 보면 다음과 같음을 알 수 있습니다.
~/sample-app/.serverless $ ls
cloudformation-template-create-stack.json
cloudformation-template-update-stack.json
sample-app.zip
serverless-state.json
```

위에 생성된 파일이 어떻게 동작하는지는 파일명만으로도 유추할 수 있습니다.

현재 cloudformation에 stack이 존재하지 않을 경우 스택을 생성한 다음,
업데이트를 하여 원하는 코드가 Lambda에 배포되도록 하는 것입니다.

serverless-state.json파일은 해당 버전의 serverless application에 대한
정보가 담겨 있습니다.

```sh
# 다시 앱의 루트디렉터리로 돌와와서 invoke를 해보겠습니다.
~/sample-app/.serverless $ cd ..
~/sample-app $ serverless invoke local --function hello
{
    "statusCode": 200,
    "body": "{\"message\":\"Go Serverless v1.0! Your function executed successfully!\",\"input\":\"\"}"
}
```

## S3 Bucket 생성하기

S3는 Object Storage로 쉽게 설명하자면 하나의 저장소입니다. 파일들을 업로드 / 다운로드 할 수 있으며 AWS에서 핵심적인 서비스 중 하나입니다.
여러 방면으로 활용할 수 있지만 여기서는 소스코드의 저장소 역할을 합니다.

S3의 메인으로 가서 버킷 생성하기 버튼을 클릭합니다.

![s3-create-btn.png](/images/s3-create-btn.png)

아래와 같이 입력하고 생성버튼을 클릭합니다.

- 버킷 이름(Bucket name): USERNAME-serverless-hands-on-1   // 여기서 USERNAME을 수정합니다. ex) khbyun-serverless-hands-on-1
- 리전(Region): 아시아 태평양(서울)

![s3-create-btn.png](/images/s3-create-1.png)

## Node.js로 크롤링 시작하기

파일 트리는 다음과 같습니다.

```txt
environment
└── serverless-crawler  : Crawler
    ├── handler.js  : Lambda에서 trigger하기 위한 handler
    ├── handler.test.js  : Local에서 handler를 trigger하기 위한 스크립트
    ├── config.yml : serverless.yml에서 사용하기 위한 변수
    ├── package.json
    └── serverless.yml : Serverless Framework config file
```

먼저 터미널을 열어 serverless-crawler 디렉터리를 생성하고 npm 초기화를 시켜줍니다.

```sh
ec2-user:~/ $ cd ~/environment
ec2-user:~/environment $ mkdir serverless-crawler && cd ec2-user:~/environment/serverless-crawler $ npm init -y
```

필요한 npm module들을 install합니다. 
여기서 aws-sdk는 개발을 위해 설치합니다. 
Lambda는 aws-sdk를 기본적으로 포함하고 있기 때문에 실제로 배포할 때는 포함시키지 않아야합니다. 
dev-dependency로 넣어두면 배포할 때 제외됩니다.

- Dependencies
  - cheerio : HTML페이지를 파싱하고, 결과 데이터를 수집하기 위한 API를 제공
  <!-- - puppeteer : DevTools Protocol을 통해 헤드가 없는 Chrome또는 Chromium을 제어하는 고급 API를 제공 -->
  - got : 몇 MB에 불과한 http 요청을 간단하게 하는 API 제공
  - dynamoose : DynamoDB를 사용하기 쉽도록 Modeling하는 도구
- Dev-Dependencies
  - aws-sdk : AWS 리소스를 사용하기 위한 SDK
  - serverless : Serverless Framework

```sh
$ npm i -S cheerio got dynamoose
$ npm i -D aws-sdk serverless
```

각 파일을 편집합니다.

### serverless-crawler/config.yml

```yml
AWS_REGION: ap-northeast-2
STAGE: dev
DEPLOYMENT_BUCKET: USERNAME-serverless-hands-on-1    # USERNAME 수정 필요!
```

### serverless-crawler/handler.js

```js
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
```

### serverless-crawler/handler.test.js

```js
const crawler = require('./handler').crawler;

crawler({}, {}, (err, result) => {
    if(err) return console.error(err);
    console.log(result);
});
```

### serverless-crawler/package.json

```json
...
...
  "description": "AWSKRUG Serverless Group의 첫번째 핸즈온 Part.2 웹크롤러 만들기입니다.😁",
  "main": "index.js",
  "scripts": {  // 이 부분을 추가합니다.
    "test": "node handler.test.js", 
    "deploy": "serverless deploy"
  },
  "repository": {
    "type": "git",
    "url": "git+https://github.com/novemberde/serverless-crawler-demo.git"
  },
  "keywords": [],
  "author": "",
...
```

### serverless-crawler/serverless.yml

```yml
service: ServerlessHandsOnPart2

provider:
  name: aws
  runtime: nodejs8.10
  memorySize: 256
  timeout: 30
  stage:  ${file(./config.yml):STAGE}
  region: ${file(./config.yml):AWS_REGION}
  deploymentBucket: ${file(./config.yml):DEPLOYMENT_BUCKET}
  environment:
    NODE_ENV: production
  iamRoleStatements:
    - Effect: Allow
      Action:
        - dynamodb:DescribeTable
        - dynamodb:Query
        - dynamodb:Scan
        - dynamodb:GetItem
        - dynamodb:PutItem
        - dynamodb:UpdateItem
        - dynamodb:DeleteItem
      Resource: "arn:aws:dynamodb:${opt:region, self:provider.region}:*:*"

functions:
  crawler:
    handler: handler.crawler
    events:
      - schedule: rate(10 minutes)

```

## DynamoDB 테이블 생성하기

DynamoDB를 설계할 시 주의해야할 점은 [FAQ](https://aws.amazon.com/ko/dynamodb/faqs/)를 참고하시길 바랍니다.

이제 DynamoDB에 Todo table을 생성할 것입니다. 파티션 키와 정렬 키는 다음과 같이 설정합니다.

- 파티션키(Partition Key): portal
- 정렬키(Sort Key): createdAt

그럼 [DynamoDB Console](https://ap-northeast-2.console.aws.amazon.com/dynamodb/home?region=ap-northeast-2#)로 이동합니다.
테이블 만들기를 클릭하여 아래와 같이 테이블을 생성합니다.

![dynamodb-create](/images/dynamodb-create.png)

그런 다음에 다시 Cloud9으로 돌아가서 테스트 코드를 돌려봅니다.

```sh
ec2-user:~/environment/serverless-crawler $ npm test

> serverless-crawler-demo@1.0.0 test/home/ec2-user/environment/serverless-crawler-demo
> node handler.test.js

success
```

[DynamoDB Console](https://ap-northeast-2.console.aws.amazon.com/dynamodb/home?region=ap-northeast-2#tables:selected=PortalKeyword)에 들어가서 성공적으로 항목들이 생성되었는지 확인합니다.

## Cloud9에서 배포하기

<!-- Cloud9을 통한 배포는 크게 어렵지 않습니다. 다음과 같이 오른쪽 위치에 Local Functions가 있습니다.
여기에는 편집하고 있는 serverlessHandsOn으로 나타날 것입니다.
우클릭을 하고 Deploy를 클릭하면 배포가 완료됩니다.

배포가 완료되면 Local Functions 아래에 Remote Functions에 해당 람다를 확인할 수 있습니다.

![c9-deploy](/images/c9-deploy.png) -->
Node가 8.x버전이 설치되어 있으면 dev-dependency에 설치된 serverless 명령어를 바로 사용할 수 있습니다.
만일 node 6.x버전이라면 Global로 serverless를 설치하여 줍니다. 현재는 8.x의 버전을 사용하기 때문에 다음 명령어는 넘어가겠습니다.

```sh
ec2-user:~/environment/serverless-crawler (master) $ npm i -g serverless
```

설치가 완료되었으면 배포를 합니다. package.json에 script에 serverless deploy를 넣어 두었기 때문에
다음과 같이 배포를 합니다.

```sh
ec2-user:~/environment/serverless-crawler (master) $ npm run deploy

> serverless-crawler@1.0.0 deploy /home/ec2-user/environment/serverless-crawler
> serverless deploy

Serverless: Packaging service...
Serverless: Excluding development dependencies...
Serverless: Uploading CloudFormation file to S3...
Serverless: Uploading artifacts...
Serverless: Uploading service .zip file to S3 (8.69 MB)...
Serverless: Validating template...
Serverless: Creating Stack...
Serverless: Checking Stack create progress...
....................
Serverless: Stack create finished...
Service Information
service: ServerlessHandsOnPart2
stage: dev
region: ap-northeast-2
stack: ServerlessHandsOnPart2-dev
api keys:
  None
endpoints:
  None
functions:
  crawler: ServerlessHandsOnPart2-dev-crawler
```

성공적으로 배포되었습니다.
지금부터 주기적으로 DynamoDB에 검색어 랭킹이 쌓입니다.

## 리소스 삭제하기

서버리스 앱은 내리는 것이 어렵지 않습니다.
간단한 Command 하나면 모든 스택이 내려갑니다.
Cloud9에서 새로운 터미널을 열고 다음과 같이 입력합니다.

```sh
$ cd ~/environment/serverless-crawler
$ serverless remove
Serverless: Getting all objects in S3 bucket...
Serverless: Removing objects in S3 bucket...
Serverless: Removing Stack...
Serverless: Checking Stack removal progress...
............
Serverless: Stack removal finished...
```


[DynamoDB Console](https://ap-northeast-2.console.aws.amazon.com/dynamodb/home?region=ap-northeast-2#)로 들어가서 Table을 삭제합니다. 리전은 서울입니다.

[Cloud9 Console](https://ap-southeast-1.console.aws.amazon.com/cloud9/home?region=ap-southeast-1)로 들어가서 IDE를 삭제합니다. 리전은 싱가포르입니다.

[S3 Console](https://s3.console.aws.amazon.com/s3/home?region=ap-southeast-1#)로 들어가서 생성된 버킷을 삭제합니다.

## References

- [https://aws.amazon.com/ko/cloud9/](https://aws.amazon.com/ko/cloud9/)
- [https://serverless.com/](https://serverless.com/)
- [https://www.npmjs.com/package/got](https://www.npmjs.com/package/got)
- [https://www.npmjs.com/package/cheerio](https://www.npmjs.com/package/cheerio)