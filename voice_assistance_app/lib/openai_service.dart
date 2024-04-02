import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:voice_assistance_app/secretkey.dart';

class OpenAIService{
  final List<Map<String, String>> messages = [];
  Future<String> isArtPromptAPI(String prompt) async{
    try{
      final resp = await http.post(Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type' : 'application/json',
        'Authorization' : 'Bearer $openAIApiKey'
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {
            'role' : 'user',
            'content' : 'Does this message want to generate an AI picture, image, art or anything similar? $prompt . Simply answer with a yes or no.',
          }
        ]
      }),
      );
      print(resp.body);
      if(resp.statusCode == 200){
        String content = json.decode(resp.body)['choices'][0]['message']['content'];
        content = content.trim();

        switch(content){
          case 'Yes':
          case 'yes':
          case 'Yes.':
          case 'yes.':
            final res = await dallEAPI(prompt);
            return res;
          default: 
            final res = await chatGPTAPI(prompt);
        }
      }
      return 'An interna; error occured';
    } catch(e) {
      return e.toString();
    }
  }
  Future<String> chatGPTAPI(String prompt) async{
    messages.add({
      'role' : 'user',
      'content' : prompt,
    });
    try{
      final resp = await http.post(Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type' : 'application/json',
        'Authorization' : 'Bearer $openAIApiKey'
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": messages
      }),
      );
      
      if(resp.statusCode == 200){
        String content = json.decode(resp.body)['choices'][0]['message']['content'];
        content = content.trim();

        messages.add({
          'role': 'assistant',
          'content' : content,
        });
        return content;
      }
      return 'An interna; error occured';
    } catch(e) {
      return e.toString();
    }
  }
  Future<String> dallEAPI(String prompt) async{
    messages.add({
      'role' : 'user',
      'content' : prompt,
    });
    try{
      final resp = await http.post(Uri.parse('https://api.openai.com/v1/images/generations'),
      headers: {
        'Content-Type' : 'application/json',
        'Authorization' : 'Bearer $openAIApiKey'
      },
      body: jsonEncode({
        'prompt': prompt,
        'n' : 1,

      }),
      );
      
      if(resp.statusCode == 200){
        String imageUrl = json.decode(resp.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();

        messages.add({
          'role': 'assistant',
          'content' : imageUrl,
        });
        return imageUrl;
      }
      return 'An interna; error occured';
    } catch(e) {
      return e.toString();
    }
  }
}