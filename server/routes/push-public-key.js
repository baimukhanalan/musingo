import { method, withApi } from '../lib/http.js';

export default withApi(async (request, response) => {
  method(request, ['GET']);
  const publicKey = process.env.VAPID_PUBLIC_KEY;
  if (!publicKey) return response.status(503).json({ error: 'push_unavailable', message: 'Push is not configured.' });
  response.setHeader('Cache-Control', 'public, max-age=3600');
  return response.status(200).json({ publicKey });
});
