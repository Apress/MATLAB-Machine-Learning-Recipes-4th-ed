%% ChatGPT interface
% Use the webwrite function to send a question to the ChatGPT API
% Save your API key. You need to log on to ChatGPT to create your own

%% Save your API key. You need to log on to ChatGPT to create your own
%% This won't work without a key
api_key = "xxxxxxyyyyyyyyzzzzzz"; % Must get your own key
setenv("OPENAI_API_KEY",api_key)

%% Set up the web options for webwrite
options = weboptions(...
    'MediaType', 'application/json','timeout',10,...
    'HeaderFields', {'Authorization' ['Bearer ' getenv('OPENAI_API_KEY')]});

%% The ChatGPT query
question = 'Write MATLAB code to plot the sine of the sequence from 0 to 10 pi';

%% The destination
url = 'https://api.openai.com/v1/chat/completions';
body = struct(...
    'model', 'gpt-3.5-turbo',...
    'messages', {{struct('role', 'user','content', question)}});

%% This writes to the web
response = webwrite(url, body, options);

%% Question and response
fprintf('Query: %s\n\n',question);
disp('Response:')
disp(response.choices.message.content)


%% Copyright
% Copyright (c) 2023 Princeton Satellite Systems, Inc.
% All rights reserved.
