// .github/scripts/update-contact-svelte.js
const fs = require('fs');
const path = require('path');

// Contact.svelte 파일 경로 (환경 변수에서 가져옴)
const CONTACT_SVELTE_PATH = process.env.CONTACT_FILE || 'Contact.svelte';

// 임시 저장된 최신 포스트 정보
const LATEST_POST_PATH = path.join(process.cwd(), '.github', 'tmp', 'latest-post.json');

function updateContactSvelte() {
  try {
    console.log('Reading latest post data...');
    console.log('Contact.svelte path:', CONTACT_SVELTE_PATH);
    
    // 최신 포스트 데이터 읽기
    if (!fs.existsSync(LATEST_POST_PATH)) {
      throw new Error('Latest post data not found');
    }
    
    const postData = JSON.parse(fs.readFileSync(LATEST_POST_PATH, 'utf8'));
    
    console.log('Reading Contact.svelte file...');
    
    // Contact.svelte 파일 읽기
    if (!fs.existsSync(CONTACT_SVELTE_PATH)) {
      throw new Error(`Contact.svelte file not found at ${CONTACT_SVELTE_PATH}`);
    }
    
    let contactSvelteContent = fs.readFileSync(CONTACT_SVELTE_PATH, 'utf8');
    
    console.log('Updating Bluesky post data in Contact.svelte...');
    
    // blueskyPost 객체를 찾아서 업데이트
    const blueskyPostRegex = /let blueskyPost = \{[^}]*\};/s;
    
    // 정규식이 매치되지 않으면 blueskyPost 형식 출력
    if (!blueskyPostRegex.test(contactSvelteContent)) {
      console.log('Sample blueskyPost format:');
      console.log(`let blueskyPost = {
        text: 'Sample text',
        publishedAt: '2025-05-01',
        url: 'https://bsky.app/profile/username'
      };`);
      throw new Error('Could not find blueskyPost object in Contact.svelte');
    }
    
    const updatedBlueskyPost = `let blueskyPost = {
    text: '${postData.text.replace(/'/g, "\\'")}',
    publishedAt: '${postData.publishedAt}',
    url: '${postData.url}'
  };`;
    
    // 파일 내용 업데이트
    contactSvelteContent = contactSvelteContent.replace(blueskyPostRegex, updatedBlueskyPost);
    
    // 파일 저장
    fs.writeFileSync(CONTACT_SVELTE_PATH, contactSvelteContent);
    console.log('Successfully updated Contact.svelte with latest Bluesky post');
    
  } catch (error) {
    console.error('Error updating Contact.svelte:', error);
    process.exit(1);
  }
}

// 실행
updateContactSvelte();
