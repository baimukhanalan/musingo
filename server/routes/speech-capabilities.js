import { hasGroqKey } from '../lib/groq.js';
import { method, withApi } from '../lib/http.js';

export default withApi(async (request, response) => {
  method(request, ['GET']);
  return response.status(200).json({
    textEvaluation: true,
    audioTranscription: hasGroqKey(),
  });
});
