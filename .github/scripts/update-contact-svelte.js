const fs = require('fs');
const path = require('path');

// Contact.svelte 파일 경로 (환경 변수에서 가져옴)
const CONTACT_SVELTE_PATH = process.env.CONTACT_FILE;

// 임시 저장된 최신 포스트 정보
const LATEST_POST_PATH = path.join(process.cwd(), '.github', 'tmp', 'latest-post.json');

function updateContactSvelte() {
  try {
    console.log('Reading latest post data...');
    console.log('Contact.svelte path:', CONTACT_SVELTE_PATH);
    
    // 파일 경로 검증
    if (!CONTACT_SVELTE_PATH) {
      throw new Error('CONTACT_FILE environment variable is not set');
    }
    
    // 최신 포스트 데이터 읽기
    if (!fs.existsSync(LATEST_POST_PATH)) {
      throw new Error(`Latest post data not found at ${LATEST_POST_PATH}`);
    }
    
    const postData = JSON.parse(fs.readFileSync(LATEST_POST_PATH, 'utf8'));
    console.log('Post data loaded:', JSON.stringify(postData, null, 2));
    
    console.log('Reading Contact.svelte file...');
    
    // Contact.svelte 파일 존재 확인
    if (!fs.existsSync(CONTACT_SVELTE_PATH)) {
      throw new Error(`Contact.svelte file not found at ${CONTACT_SVELTE_PATH}`);
    }
    
    let contactSvelteContent = fs.readFileSync(CONTACT_SVELTE_PATH, 'utf8');
    console.log('Contact.svelte file loaded, size:', contactSvelteContent.length);
    
    console.log('Updating Bluesky post data in Contact.svelte...');
    
    // blueskyPost 객체를 찾아서 업데이트
    const blueskyPostRegex = /let\s+blueskyPost\s*=\s*\{[^}]*\};/s;
    
    // 정규식이 매치되지 않으면 오류 출력
    if (!blueskyPostRegex.test(contactSvelteContent)) {
      console.log('Content preview:', contactSvelteContent.substring(0, 500) + '...');
      console.log('Sample blueskyPost format:');
      console.log(`let blueskyPost = {
        text: 'Sample text',
        publishedAt: '2025-05-01',
        url: 'https://bsky.app/profile/username'
      };`);
      throw new Error('Could not find blueskyPost object in Contact.svelte');
    }
    
    // 텍스트에서 특수 문자 이스케이프 처리
    const escapedText = postData.text
      .replace(/'/g, "\\'")
      .replace(/\n/g, "\\n")
      .replace(/\r/g, "\\r");
    
    const updatedBlueskyPost = `let blueskyPost = {
    text: '${escapedText}',
    publishedAt: '${postData.publishedAt}',
    url: '${postData.url}'
  };`;
    
    // 파일 내용 업데이트
    const updatedContent = contactSvelteContent.replace(blueskyPostRegex, updatedBlueskyPost);
    
    // 파일 변경 여부 확인
    if (updatedContent === contactSvelteContent) {
      console.log('No changes needed to Contact.svelte, content is already up to date');
    } else {
      // 파일 저장
      fs.writeFileSync(CONTACT_SVELTE_PATH, updatedContent);
      console.log('Successfully updated Contact.svelte with latest Bluesky post');
    }
    
  } catch (error) {
    console.error('Error updating Contact.svelte:', error.message);
    console.error(error.stack);
    process.exit(1);
  }
}

// 실행
updateContactSvelte();
