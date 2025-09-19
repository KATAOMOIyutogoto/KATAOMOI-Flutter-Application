export default async function handler(req, res) {
  const { cardId } = req.query;
  
  // 環境変数から設定を取得
  const supabaseUrl = process.env.SUPABASE_URL;
  const supabaseServiceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  const fallbackUrl = process.env.FALLBACK_URL || 'https://kataomoi.jp/safety';
  
  // デバッグ情報を出力
  console.log('Redirect API called with cardId:', cardId);
  console.log('Supabase URL:', supabaseUrl);
  console.log('Service Role Key exists:', !!supabaseServiceRoleKey);
  
  try {
    // カードIDが提供されていない場合
    if (!cardId) {
      console.log('No cardId provided, redirecting to fallback');
      return res.redirect(302, fallbackUrl);
    }
    
    // Supabaseからカード情報を取得
    const response = await fetch(`${supabaseUrl}/rest/v1/cards?id=eq.${cardId}`, {
      headers: {
        'apikey': supabaseServiceRoleKey,
        'Authorization': `Bearer ${supabaseServiceRoleKey}`,
        'Content-Type': 'application/json',
      },
    });
    
    console.log('Supabase response status:', response.status);
    
    if (!response.ok) {
      console.error('Supabase API error:', response.status, response.statusText);
      return res.redirect(302, fallbackUrl);
    }
    
    const data = await response.json();
    console.log('Supabase response data:', data);
    
    // カードが見つからない場合
    if (!data || data.length === 0) {
      console.log('Card not found:', cardId);
      return res.redirect(302, fallbackUrl);
    }
    
    const card = data[0];
    const redirectUrl = card.current_url;
    
    // リダイレクトURLが設定されていない場合
    if (!redirectUrl) {
      console.log('No redirect URL set for card:', cardId);
      return res.redirect(302, fallbackUrl);
    }
    
    // リダイレクト実行
    console.log(`Redirecting ${cardId} to ${redirectUrl}`);
    return res.redirect(302, redirectUrl);
    
  } catch (error) {
    console.error('Redirect error:', error);
    return res.redirect(302, fallbackUrl);
  }
}
