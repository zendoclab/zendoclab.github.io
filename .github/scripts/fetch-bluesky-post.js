// .github/scripts/fetch-bluesky-post.js
const fs = require('fs');
const { BskyAgent } = require('@atproto/api');
const { format } = require('date-fns');

// Bluesky 인증 정보
const BLUESKY_USERNAME = process.env.BLUESKY_USERNAME;
const BLUESKY_EMAIL = process.env.BLUESKY_EMAIL;
const BLUESKY_PASSWORD = process.env.BLUESKY_PASSWORD;

async function fetchLatestPost() {
  try {
    console.log('Connecting to Bluesky API...');
    
    // Bluesky API 에이전트 생성
    const agent = new BskyAgent({
      service: 'https://bsky.social',
    });

    // Bluesky 로그인
    await agent.login({
      identifier: BLUESKY_EMAIL,
      password: BLUESKY_PASSWORD,
    });

    console.log('Successfully logged in to Bluesky');

    // 프로필 정보 가져오기
    const profile = await agent.getProfile({ actor: BLUESKY_USERNAME });
    const did = profile.data.did;

    // 해당 사용자의 최신 포스트 가져오기
    const response = await agent.getAuthorFeed({
      actor: did,
      limit: 1, // 가장 최근 포스트 1개만 가져옴
    });

    if (!response.success || !response.data.feed.length) {
      throw new Error('Failed to fetch posts or no posts found');
    }

    // 최신 포스트 정보 추출
    const latestPost = response.data.feed[0];
    const postText = latestPost.post.record.text;
    const publishedAt = new Date(latestPost.post.indexedAt).toISOString().split('T')[0]; // YYYY-MM-DD 형식
    const postUrl = `https://bsky.app/profile/${BLUESKY_USERNAME}/post/${latestPost.post.uri.split('/').pop()}`;

    console.log('Latest post found:', postText);

    // 결과를 파일로 저장
    const postData = {
      text: postText,
      publishedAt: publishedAt,
      url: postUrl
    };

    fs.writeFileSync('.github/tmp/latest-post.json', JSON.stringify(postData, null, 2));
    
    // 새로운 환경 파일 방식으로 출력 변수 설정 (set-output 대신)
    fs.appendFileSync(process.env.GITHUB_OUTPUT || '', `post_text=${postText}\n`);
    fs.appendFileSync(process.env.GITHUB_OUTPUT || '', `published_at=${publishedAt}\n`);
    fs.appendFileSync(process.env.GITHUB_OUTPUT || '', `post_url=${postUrl}\n`);

    return postData;
  } catch (error) {
    console.error('Error fetching latest Bluesky post:', error);
    
    // 오류가 발생하면 기본값 반환
    return {
      text: 'Anandamide Surge - brain rebooted via multitasking',
      publishedAt: '2025-05-03',
      url: `https://bsky.app/profile/${BLUESKY_USERNAME}`
    };
  }
}

// 임시 디렉토리 생성
if (!fs.existsSync('.github/tmp')) {
  fs.mkdirSync('.github/tmp', { recursive: true });
}

// 실행
fetchLatestPost().catch(error => {
  console.error('Unhandled error in fetchLatestPost:', error);
  process.exit(1);
});
