%% Save your API key. You need to log on to ChatGPT to create your own
% This won't work without a key
api_key = "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";
setenv("OPENAI_API_KEY",api_key)

%% Set up the web options for webwrite
options = weboptions(...
    'MediaType', 'application/json','timeout',10,...
    'HeaderFields', {'Authorization' ['Bearer ' getenv('OPENAI_API_KEY')]});

%% The ChatGPT query
question = 'Write MATLAB code plot the sine of the sequence from 0 to 10 pi';

%% The destination
url = 'https://api.openai.com/v1/chat/completions';
body = struct(...
    'model', 'gpt-3.5-turbo',...
    'messages', {{struct('role', 'user','content', question)}});

%% This writes to the web
response = webwrite(url, body, options);

%% Question and response
disp(question)
disp(response.choices.message.content)
