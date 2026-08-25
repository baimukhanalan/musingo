import { method, withApi } from '../lib/http.js';
import { hasSpeechTranscriptionProvider } from '../lib/speech-transcription.js';

export default withApi(async (request, response) => {
  method(request, ['GET']);
  return response.status(200).json({
    textEvaluation: true,
    audioTranscription: hasSpeechTranscriptionProvider(),
  });
});
