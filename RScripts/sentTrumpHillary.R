
# Simple Sentiment Analysis for Twitter

# Global parameters 
  
setwd("~/Desktop/R/Text_Analysis/")

#Source Multiplot Function
source("RScripts/multiplot.R")

# Include necessary packages
library(twitteR)
library(plyr)
library(stringr)
library(ggplot2)
library(reshape2)



  
# Load data 
load("~/Desktop/R/Text_Analysis/data/twitter/realdonaldtrump2016-07-07.RData")
trump.text = sapply(tweets, function(x) x$text)
load("~/Desktop/R/Text_Analysis/data/twitter/hillaryclinton2016-07-07.RData")
hillary.text = sapply(tweets, function(x) x$text)
 
# Loading the Opinion Lexicons to Determine Sentiment
#This is an essential step for sentiment analysis. These text documents from Hu and Liu, 2004* are filled with positive and negative words, respectively. The algorithm we will write next will check these documents to score each word in the tweet. If the algorithm runs across the word "love" in a tweet, it will check the positive-words.txt file, find "love" is included, and score the word with a +1. More on that in a second...

lex.pos = scan('~/Desktop/R/Text_Analysis/data/opinionLexicon/positive-words.txt', what='character', comment.char = ';')
lex.neg = scan('~/Desktop/R/Text_Analysis/data/opinionLexicon/negative-words.txt', what='character', comment.char = ';')

# Add words relevant to our corpus using the combine c() function:
  
pos.words = c(lex.pos)
neg.words = c(lex.neg)

# Implement the sentiment scoring algorithm
score.sentiment = function(tweets, pos.words, neg.words, .progress='none')
{
  
  #figure out the score for each tweet specifically
  scores = laply(tweets, function(tweet, pos.words, neg.words) {
    #normalize tweet text
    tweet = gsub('[[:punct:]]', '', tweet)
    tweet = gsub('[[:cntrl:]]', '', tweet)
    tweet = gsub('\\d+', '', tweet)
    
    #REMOVE EMOJIS!
    tweet = iconv(tweet, "ASCII", "UTF-8", sub="")
    
    tweet.lower = tolower(tweet)
    
    #split list into separate words
    word.list = str_split(tweet.lower, '\\s+')
    words = unlist(word.list)
    
    #compare our words to the dictionaries of positive and negative terms using match function
    pos.matches = match(words, pos.words)
    neg.matches = match(words, neg.words)
    
    #match returns a position of the matched term or NA, but we just want the TRUE/FALSE, not NA
    pos.matches = !is.na(pos.matches)
    neg.matches = !is.na(neg.matches)
    
    #the score of each tweet is the sum of the positive matches minus the sum of the negative matches
    score = sum(pos.matches) - sum(neg.matches)
    
    return(score)
  }, pos.words, neg.words, .progress = .progress)
  
  #compile the scores and text of tweets into a data frame for plotting
  scores.df = data.frame(score=scores, text = tweets)
  return(scores.df)
}

trump.result = score.sentiment(trump.text, pos.words, neg.words)
hillary.result = score.sentiment(hillary.text, pos.words, neg.words)

df.result <- data.frame(x = trump.result, y = hillary.result)

ggplot(melt(df.result), aes(value, fill = variable)) + geom_histogram(position = "dodge")






#Acknowledgements: This algorithm was adapted from Jeffrey Breen's Mining Twitter for Airline Consumer Sentiment article. You can find it here: http://www.inside-r.org/howto/mining-twitter-airline-consumer-sentiment. 

#Reference: Liu, Minqing Hu and Junsheng Cheng. "Opinion Observer: Analyzing and Comparing Opinions on the Web." Proceedings of the 14th International World Wide Web conference (WWW-2005), May 10-14, 2005, Chiba, Japan.



