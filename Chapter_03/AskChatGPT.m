%% ASKCHATGPT Ask ChatGPT a question
%% Form
% [answer,question] = AskChatGPT( question )
%% Description
% Use webwrite to call ChatGPT over the web. You should obtain your own API
% key. If a question is not input the function will query the user with an
% input dialog. If there are no outputs, the answer it wrapped and
% displayed to the screen.
%
% Here are some examples:
%   'How do you write MATLAB code to solve an equation'
%   Write MATLAB code plot the sine of the sequence from 0 to 10 pi
%
%% Inputs
%   question   ''    Question to ask ChatGPT, string
%
%% Outputs
%   answer     ''    Answer string
%   question   ''    Question string

function [answer,question] = AskChatGPT( question )

if nargin < 1 || isempty(question)
  questions = inputdlg('Type a question to ask ChatGPT:');
  question = questions{1};

  if isempty(question)
    question = 'What is the square root of 2?';
    question = {''};
  end
end

api_key = "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";
setenv("OPENAI_API_KEY",api_key)

% Set up the web options
options = weboptions(...
    'MediaType', 'application/json',...
    'Timeout',10,...
    'HeaderFields', {'Authorization' ['Bearer ' getenv('OPENAI_API_KEY')]}...
);

% The destination
url = 'https://api.openai.com/v1/chat/completions';
body = struct(...
    'model', 'gpt-3.5-turbo',...
    'messages', {{struct('role', 'user','content', question)}});

% This writes to the web
response = webwrite(url, body, options);

answer = response.choices.message.content;
if nargout==0
  disp('Question:')
  disp(question)
  disp('Answer:')
  outdisp = textwrap({answer}, 60);
  disp(outdisp)
end