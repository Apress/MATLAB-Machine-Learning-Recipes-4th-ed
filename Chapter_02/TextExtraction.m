filename = "Chapter.pdf";
str = extractFileText(filename);

start = "CHAPTER";
fin = "NumberOfSamples";
snippet = extractBetween(str,start,fin)

test = "my niw string";
docs = tokenizedDocument(test)
updatedDocuments = correctSpelling(docs)