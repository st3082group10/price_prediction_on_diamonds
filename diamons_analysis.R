dataset = read.csv("diamonds.csv")
head(dataset)

# Cleaning the dataset
# Removing unusual observations
dataset = dataset[!(dataset$x == 0 | dataset$y == 0 | dataset$z == 0),]
depth2 = numeric(0)
for (i in 1:nrow(dataset)) {
  depth2[i] = (dataset$z[i]/mean(c(dataset$x[i], dataset$y[i])))*100
}

df = dataset[abs(dataset$depth - depth2) > 1,]
nrow(df)

dataset = dataset[!(abs(dataset$depth - depth2) > 1),]

# Applying transformations
dataset$ln_price = log(dataset$price)
dataset$ln_carat = log(dataset$carat)

# feature engineering
dataset$vol = dataset$x*dataset$y*dataset$z

dataset$cut = factor(dataset$cut , levels=c("Fair", "Good", "Very Good", "Premium", "Ideal"))
dataset$clarity = factor(dataset$clarity , levels=c("I1", "SI2", "SI1", "VS2", "VS1", "VVS2", "VVS1", "IF"))
dataset$color = factor(dataset$color , levels=c("J","I","H","G","F","E","D"))

# Splitting the dataset into training and test data
set.seed(1234)
test_index = sample(1:nrow(dataset), nrow(dataset)*0.2)
test = dataset[test_index,]
train = dataset[-test_index,]
train_numeric = train[,c(6,7,9:14)]
head(train_numeric)

#------------------ Descriptive Analysis -----------------------------------------------------

# Loading required libraries
library(car)
library(reshape2)
library(ggplot2)
library(RColorBrewer)
library(GGally)
library(packHV)

# creating correlation matrix
corr_mat <- round(cor(train_numeric),3)

# reduce the size of correlation matrix
melted_corr_mat <- melt(corr_mat)
head(melted_corr_mat)

# plotting the correlation heatmap

cor_map = ggplot(data = melted_corr_mat, aes(x=Var1, y=Var2,
                                             fill=value)) +
  geom_tile() +
  theme(axis.text = element_text(size=15), axis.title = element_blank(),
        panel.background = element_blank(), axis.ticks = element_blank(),
        legend.key.size = unit(1, 'cm')) +
  geom_text(aes(Var2, Var1, label = value),
            color = "black", size = 6)

ggpairs(train_numeric, lower=list(continuous="smooth", params=c(colour="#2E5B88")),
        diag=list(continuous="bar", params=c(colour="#6baed6")), 
        upper=list(params=list(corSize=6)), axisLabels='show')

# Scatterplot matrix

lowerFn <- function(data, mapping, method = "lm", ...) {
  p <- ggplot(data = data, mapping = mapping) +
    geom_point(colour = "#2E5B88") +
    geom_smooth(method = method, color = "darkblue", ...)
  p
}

ggpairs(
  train_numeric, lower = list(continuous = wrap(lowerFn, method = "lm")),
  diag = list(continuous = wrap("barDiag", colour = "#6baed6")),
  upper = list(continuous = wrap("cor", size = 4))
)


# Distribution of Price
hist_boxplot(train$price, col = "#6baed6", xlab = "price", main = "Price")
hist_boxplot(train$ln_price, col = "#6baed6", xlab = "ln_price", main = "log(Price)")


# Price vs Categorical variables
Price_cut = ggplot(train, aes(x = cut, y = ln_price, fill = cut)) + 
  geom_boxplot(outlier.colour="black", outlier.shape=16, outlier.size=2,show.legend = F)+
  scale_fill_brewer(palette="Blues")+
  stat_summary(fun="mean", show.legend = F)

Price_color = ggplot(train, aes(x = color, y = ln_price, fill = color)) + 
  geom_boxplot(outlier.colour="black", outlier.shape=16, outlier.size=2,show.legend = F)+
  scale_fill_brewer(palette="Blues")+
  stat_summary(fun="mean", show.legend = F)

Price_clarity = ggplot(train, aes(x = clarity, y = ln_price, fill = clarity)) + 
  geom_boxplot(outlier.colour="black", outlier.shape=16, outlier.size=2,show.legend = F)+
  scale_fill_brewer(palette="Blues")+
  stat_summary(fun="mean", show.legend = F)

price_carat = ggplot(train, aes(x=carat, y=price)) + 
  geom_point(color = "#2A5783")+
  theme_classic()

# Scatterplot of ln(price) vs ln(carat)
lnprice_lncarat = ggplot(train, aes(x=ln_carat, y=ln_price)) + 
  geom_point(color = "#2A5783")

# ln(price) vs x,y,z
price_x = ggplot(train, aes(x=x, y=ln_price)) + 
  geom_point(color = "darkblue")

price_y = ggplot(train, aes(x=y, y=ln_price)) + 
  geom_point(color = "darkblue")

price_z = ggplot(train, aes(x=z, y=ln_price)) + 
  geom_point(color = "darkblue")


# table vs ln_price
ggplot(train, aes(x=table, y=ln_price)) + 
  geom_point(color = "darkblue")
# no linear relationship

# Scatterplots by groups

ggplot(train, aes(x=ln_carat, y=ln_price, color=clarity)) + 
  geom_point()+
  scale_color_brewer(palette="Blues")+
  theme(panel.background = element_rect(fill = "#B6B3B2"),
        panel.grid = element_line(color = "#A6A3A3"))

ggplot(train, aes(x=ln_carat, y=ln_price, color=color)) + 
  geom_point()+
  scale_color_brewer(palette="Blues")+
  theme(panel.background = element_rect(fill = "#B6B3B2"),
        panel.grid = element_line(color = "#A6A3A3"))

ggplot(train, aes(x=ln_carat, y=ln_price, color=color)) + 
  geom_point()+
  scale_color_brewer(palette="Blues")+
  theme(panel.background = element_rect(fill = "#B6B3B2"),
        panel.grid = element_line(color = "#A6A3A3"))+
  facet_wrap(~clarity)

ggplot(train, aes(x=ln_carat, y=ln_price, color=cut)) + 
  geom_point()+
  scale_color_brewer(palette="Blues")+
  theme(panel.background = element_rect(fill = "#B6B3B2"),
        panel.grid = element_line(color = "#A6A3A3"))

ggplot(train, aes(x=ln_carat, y=ln_price)) + 
  geom_point() + 
  facet_wrap(~cut) # create a ribbon of plots using cut


# Create a violin plot to show the distribution of price across different levels of cut
ggplot(data = train, aes(x = cut, y = ln_price, fill = cut)) + 
  geom_violin()

color_clarity = table(train$color, train$clarity)
chisq.test(color_clarity)

color_cut = table(train$color, train$cut)
chisq.test(color_cut)

# Comparing groups
leveneTest(ln_price ~ color, data = train) # Checking the variance assumption to apply anova. It fails. Therefore applying KW 
kruskal.test(ln_price ~ color,data = train)

leveneTest(ln_price ~ cut, data = train)
kruskal.test(ln_price ~ cut,data = train)

leveneTest(ln_price ~ clarity, data = train)
kruskal.test(ln_price ~ clarity,data = train)

nrow(train)
dataset[dataset$X == 49774,]
dataset[dataset$carat > 0.65 & dataset$carat < 0.68,]

ggplot(train, aes(ln_carat, ln_price, color = clarity)) +
  geom_point(alpha = 0.5) +
  theme(panel.background = element_rect(fill = "#B6B3B2"),
        panel.grid = element_line(color = "#A6A3A3")) +
  scale_color_brewer(palette="Blues")+
  geom_smooth(method="lm", se=F) + 
  labs(title = "Price vs Carat Grouped by Clarity",
       subtitle = "Diamonds dataset",
       x = "Diamond Carat",
       y = "Price",
       color = "Diamond Clarity")

#------------------Further Analysis -----------------------------------------------------

# Principle Component Analysis

library(remotes)
library(ggplot2)
library(corrplot)
library(factoextra)
train_p=train

# coding the ordinal variables
train_p$cut <- as.numeric(train_p$cut)
train_p$clarity <- as.numeric(train_p$clarity)
train_p$color <- as.numeric(train_p$color)
test$cut <- as.numeric(test$cut)
test$clarity <- as.numeric(test$clarity)
test$color <- as.numeric(test$color)

pca_train=train_p[,c(3:7,9:11,13,14)]

corrplot(cor(pca_train),method = "number")

# PCA
#diamonds_pca=pca(pca_train,9,scale=T)
diamonds_pca <- princomp(as.matrix(pca_train[,sapply(pca_train, class) == "numeric"]),cor=T)
#diamonds_pca=prcomp(pca_train,center=TRUE,scale. = TRUE)
summary(diamonds_pca)

#cor(diamonds_pca)
plot(diamonds_pca,type="l")
print(diamonds_pca)
#str(diamonds_pca)

# PCA plots
#fviz_pca_biplot(diamonds_pca,col.var='red')
fviz_pca_var(diamonds_pca,repel = T,title="loadings plot",col.var = "contrib",gradient.cols=c("#00AFBB","#E7B800","#FC4E07"))
fviz_screeplot(diamonds_pca)

#eigen values of the respective components
diamonds_pca$sdev^2
fviz_eig(diamonds_pca,addlabels = T)

# Cluster Analysis

# Scaling variables
library(magrittr)
library(dplyr)
train_scale = train %>% select(-X,-cut,-color,-clarity) %>%scale()
head(train_scale)

# Determine & visualize optimal number of clusters
library(factoextra)
fviz_nbclust(train_scale, kmeans, method = "silhouette")

# cluster Analysis with Kmeans
km.out=kmeans(train_scale,2)

set.seed(100)
diamonds_cluster= kmeans(train_scale, centers = 2)
train$cluster= diamonds_cluster$cluster

fviz_cluster(diamonds_cluster, data = train_scale)

# characteristics of the different clusters
train %>% select(-X,-cut,-color,-clarity) %>% 
  group_by(cluster) %>% 
  summarise_all(mean)

# Price vs Clusters
train %>%
  ggplot(., aes(x = cluster, y = price, color = cluster)) +
  geom_jitter(alpha=0.7) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle=65, vjust=0.6)) + 
  labs(title = "Price vs Clusters",
       subtitle = "Diamonds train dataset",
       x = "Diamond Cluster",
       y = "Price",
       color = "Diamond Cluster")