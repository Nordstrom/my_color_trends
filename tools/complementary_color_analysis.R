require(arules) 
require(arulesViz) 
require(ggplot2)
require(bigmemory)
require(foreach)
require(bigtabulate)
require(plyr)
require(lattice)
require(ape)
require(doParallel)

setwd('/Users/x1lh/projects/color/data')

# DVL
x11 = read.delim('x11_colors.txt', 
                 header = TRUE, 
                 sep = '\t')

x11$rgb = gsub('{', '', x11$rgb, fixed = TRUE)
x11$rgb = gsub('}', '', x11$rgb, fixed = TRUE)

## Construct rgb data frame to plot
temp = strsplit(x11$rgb, ',')
temp = unlist(temp)
rgb = as.data.frame(matrix(temp, ncol = 3, byrow = TRUE))
colnames(rgb) = c('r', 'g', 'b')
rgb$r = as.numeric(as.character(rgb$r))
rgb$g = as.numeric(as.character(rgb$g))
rgb$b = as.numeric(as.character(rgb$b))
rgb$r_perc = rgb$r / 255
rgb$g_perc = rgb$g / 255
rgb$b_perc = rgb$b / 255

x11 = cbind(x11, rgb)
x11$hex = rgb(x11$r_perc, x11$g_perc, x11$b_perc)

photo = read.delim('photo_colors.txt', 
                   header = TRUE, 
                   sep = '\t')

color_data = merge(photo, x11, by = 'color_id')


# JV
pantone = read.delim('pantone_all.tsv', sep = '\t', header = FALSE)

# Transactional data
trans = read.delim('leadership_tran_data_no_quotes.txt', 
                    header = TRUE, 
                    sep = '\t')

# Product catalog
catalog = pd.read_csv('/Users/x1lh/projects/color/data/product_catalog.txt', header = 0, sep = '\t')

# Data of form photo_id, color
color_sets = data.frame(photo_group_id = color_data$photo_group_id,
                        color = color_data$name)
color_sets = arrange(color_sets, photo_group_id, color)

## Distribution of RGB
point_colors = rgb(x11$r_perc, x11$g_perc, x11$b_perc)
op = par(bg = "#c4a879")
scatterplot3d(as.matrix(cbind(x11$r, x11$g, x11$b)),
              pch = 19,
              lty.hplot = 1,
              color = point_colors,
              xlim = c(0, 255),
              ylim = c(0, 255),
              zlim = c(0, 255),
              scale.y = 0.75,
              xlab = 'R',
              ylab = 'G',
              zlab = 'B',
              tick.marks = TRUE,
              cex.symbols = 1.10,
              main = 'X11 RGB Colorspace',
              type = 'h',
              grid = TRUE,
              box = FALSE,
              y.margin.add = 1)

## Measure the distance between the rgb's
mat = as.matrix(cbind(x11$r, x11$g, x11$b))
rownames(mat) = x11$name
colnames(mat) = c('r', 'g', 'b')

hc = hclust(dist(mat), "complete")

op = par(bg = "#c4a879")
plot.phylo(as.phylo(hc), 
     type = 'fan',
     tip.color = point_colors, 
     label.offset = 1,
     cex = 0.65)

op = par(bg = "#c4a879")
plot.phylo(as.phylo(hc), 
     type = 'fan',
     tip.color = point_colors, 
     label.offset = 1,
     cex = 1,
     open.angle = 180,
     edge.width = 2,
     no.margin = TRUE,
     rotate.tree = 180)
dev.off()
plot.phylo(as.phylo(hc), 
      type = 'fan',
      tip.color = point_colors, 
      label.offset = 1,
      cex = 1.70,
      open.angle = 180,
      edge.width = 3,
      no.margin = TRUE,
      edge.color = rgb(146 / 255, 145 / 255, 141 / 255),
      rotate.tree = 180, x.lim = c(-60, 60), y.lim = c(-290, 5))

plot.phylo(as.phylo(hc), 
      type = 'fan',
      tip.color = point_colors, 
      label.offset = 1,
      cex = 1.70,
      open.angle = 180,
      edge.width = 3,
      no.margin = TRUE,
      edge.color = rgb(146 / 255, 145 / 255, 141 / 255),
      rotate.tree = 180, x.lim = c(-60, 60), y.lim = c(-290, 5))

distance = as.matrix(dist(mat),
     diag = TRUE,
     upper = TRUE)

heatmap.2(distance,
          trace = 'none',
          col = grey(seq(1, 0, -0.01)),
          ColSideColors = point_colors,
          RowSideColors = point_colors,
          cexRow = 0.30,
          cexCol = 0.30)

## Do k-means to cluster colors into broader bins
rgb_scaled = scale(mat)

# Determine number of clusters
wss = (nrow(rgb_scaled) - 1) * sum(apply(rgb_scaled, 2, var))

for (i in 2:80) {
  wss[i] =  sum(kmeans(rgb_scaled, centers = i)$withinss)
}
plot(1:80, 
    wss, 
    type = "b", 
    xlab = "Number of Clusters",
    ylab = "Within groups sum of squares")

# Use around 20 clusters to start
fit = kmeans(rgb_scaled, 20)
mat_with_clusters = data.frame(cbind(mat, fit$cluster))
colnames(mat_with_clusters) = c('r', 'g', 'b', 'cluster')
mat_with_clusters$color_name = rownames(mat)
mat_with_clusters = arrange(mat_with_clusters, cluster)

# Calculate the average color value per cluster
mat_with_clusters = ddply(mat_with_clusters,
                   .(cluster),
                   transform,
                   mean_r = mean(r),
                   mean_g = mean(g),
                   mean_b = mean(b))
mat_with_clusters$hex = rgb(mat_with_clusters$r / 255, 
                            mat_with_clusters$g / 255, 
                            mat_with_clusters$b / 255)

mat_with_clusters$mean_hex = rgb(mat_with_clusters$mean_r / 255, 
                            mat_with_clusters$mean_g / 255, 
                            mat_with_clusters$mean_b / 255)

## Plot clustered RGB space
op = par(bg = "#c4a879")
scatterplot3d(as.matrix(cbind(mat_with_clusters$mean_r, 
                        mat_with_clusters$mean_g, 
                        mat_with_clusters$mean_b)),
              pch = 19,
              lty.hplot = 1,
              color = mat_with_clusters$mean_hex,
              xlim = c(0, 255),
              ylim = c(0, 255),
              zlim = c(0, 255),
              scale.y = 0.75,
              xlab = 'R',
              ylab = 'G',
              zlab = 'B',
              tick.marks = TRUE,
              cex.symbols = 1.10,
              main = 'X11 Colorspace Reduced with K-means Clustering',
              sub = '50 Clusters',
              type = 'h',
              grid = TRUE,
              box = FALSE,
              y.margin.add = 1)

# Plot cluster memberships
mat_with_clusters$color = factor(mat_with_clusters$color_name, 
                                 levels = mat_with_clusters$color_name,
                                 ordered = TRUE)

ggplot(mat_with_clusters, aes(x = factor(1), y = factor(color_name))) +
       geom_tile(aes(fill = mean_hex)) +
       scale_fill_identity() +
       labs(title = '20 Clusters') +
       scale_x_discrete('', expand = c(0, 0)) +
       scale_y_discrete('', expand = c(0, 0)) + 
       theme_bw() +
       theme(line = element_blank(),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            panel.border = element_blank(),
            plot.background = element_rect(fill = '#c4a879'),
            axis.ticks = element_blank(),
            axis.text.y = element_text(size = 4, color = mat_with_clusters$hex),
            axis.text.x = element_blank())

###################
## Market basket ##
###################
color_sets = data.frame(photo_group_id = color_data$photo_group_id,
                        color = color_data$name)
color_sets = arrange(color_sets, photo_group_id, color)
color_sets = unique(data.frame(photo_group_id = factor(color_sets$photo_group_id),
                        cluster = factor(color_sets$color)))
#write.table(color_sets, 'color_sets_full.txt', sep = '\t', row.names = FALSE)
basket = read.transactions('color_sets_full.txt', 
	format = 'single',
	cols = c(1, 2))
rules = apriori(basket,
                parameter = list(supp = 0.0001, 
                                 minlen = 2,
                                 conf = 0.0001, 
                                 target = 'rules'))
full_rules = as(rules, "data.frame")
#write.table(full_rules, 'full_rules.txt', sep = '\t', row.names = FALSE)

# With 20 clusters       
color_sets = data.frame(photo_group_id = color_data$photo_group_id,
                        color = color_data$name)
color_sets = merge(color_sets, mat_with_clusters[ , c('color_name', 'cluster')], 
                   by.x = 'color', 
                   by.y = 'color_name')
color_sets = arrange(color_sets, photo_group_id, cluster, color)
color_sets$color = NULL
color_sets = unique(data.frame(photo_group_id = factor(color_sets$photo_group_id),
                        cluster = factor(color_sets$cluster)))
#write.table(color_sets, 'color_sets.txt', sep = '\t', row.names = FALSE)

basket = read.transactions('color_sets_20_clusters.txt', 
	format = 'single',
	cols = c(1, 2))

rules_20 = apriori(basket,
                parameter = list(supp = 0.0001, 
                                 minlen = 2,
                                 conf = 0.0001, 
                                 target = 'rules'))

rules_20 = as(rules_20, "data.frame")

itemFrequencyPlot(basket, topN = 20)

## Plot complementary color sets
rules$rules = gsub('\\{', '', rules$rules)
rules$rules = gsub('\\}', '', rules$rules) 
rules = ddply(rules,
             1,
             transform,
             lhs = strsplit(rules, ' => ')[[1]][1],
             rhs = strsplit(rules, ' => ')[[1]][2])

hex = unique(mat_with_clusters[ , c('color_name', 'hex')])

## Complementary color plots
plot_rules = data.frame(pair_number = c(1:length(simple_rules$rules), 1:length(simple_rules$rules)),
                        color = c(as.character(simple_rules$rhs), as.character(simple_rules$lhs)),
                        group = c(rep('target', length(simple_rules$rules)), rep('comp', length(simple_rules$rules))),
                        bin_width = 1,
                        lift = c(simple_rules$lift, simple_rules$lift))

plot_rules = merge(plot_rules, mat_with_clusters[ , c('color_name', 'hex')], by.x = 'color', by.y = 'color_name')
plot_rules$group = as.character(plot_rules$group)
plot_rules = arrange(plot_rules, pair_number, -group)

# lavender 
turquoise_pairs = plot_rules[which(plot_rules$color == 'Medium Turquoise' & plot_rules$group == 'target'), ]$pair_number

ggplot(plot_rules[plot_rules$pair_number %in% turquoise_pairs, ], aes(x = factor(group, levels = c('target', 'comp')), y = factor(round(lift, 2)), width = bin_width)) +
       geom_tile(aes(fill = hex)) +
       scale_fill_identity() +
       #labs(title = 'Lavender with Color Complements') +
       scale_x_discrete('', expand = c(0, 0), labels = c('Target Color', 'Complementary Color')) +
       scale_y_discrete('', expand = c(0, 0)) + 
       theme_bw() +
       theme(line = element_blank(),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            panel.border = element_blank(),
            #plot.background = element_rect(fill = '#c4a879'),
            axis.ticks = element_blank(),
            axis.text.y = element_blank(),
            axis.text.x = element_text(size = 13),
            axis.title.y = element_text(size = 16))

orange_pairs = plot_rules[which(plot_rules$color == 'Cadet Blue' & plot_rules$group == 'target'), ]$pair_number

ggplot(plot_rules[plot_rules$pair_number %in% orange_pairs, ], aes(x = factor(group, levels = c('target', 'comp')), y = factor(round(lift, 2)), width = bin_width)) +
       geom_tile(aes(fill = hex)) +
       scale_fill_identity() +
       #labs(title = 'Lavender with Color Complements') +
       scale_x_discrete('', expand = c(0, 0), labels = c('Target Color', 'Complementary Color')) +
       scale_y_discrete('', expand = c(0, 0)) + 
       theme_bw() +
       theme(line = element_blank(),
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            panel.border = element_blank(),
            #plot.background = element_rect(fill = '#c4a879'),
            axis.ticks = element_blank(),
            axis.text.y = element_blank(),
            axis.text.x = element_text(size = 13),
            axis.title.y = element_text(size = 16))


test_pair = data.frame(pair_number = c(1, 1, 1, 1, 2, 2, 3, 3, 3), 
                       color = c('#5f75e6', '#e6d05f', '#b9e65f', '#8c5fe6', '#5f75e6', '#5fb9e6', '#5f75e6', '#b9e65f', '#e68d5f'),
                       group = c(2, 1, 2, 1, 2, .75, 1.25),
                       bin_width = c(1, 1, 1, 1, 1, .5, .5))

## for multiple colors have between 0 and 1.5 so can just use 1.5 / # colors.

ggplot(test_pair, aes(x = group, y = factor(pair_number), width = bin_width)) +
       geom_tile(aes(fill = color)) +
       scale_fill_identity() +
       scale_x_continuous('', breaks = c(1,2), labels = c("comp", "target"), expand = c(0, 0)) +
       scale_y_discrete('', expand = c(0, 0)) + 
       theme_bw()


## Jimmy Viz x11
jv11 = read.delim('x11_all_with_headers.tsv', sep = '\t', header = TRUE)
jv11 = arrange(jv11, swatch_photo_id, color_name, color_space)

jv11_sub = jv11[ , c('swatch_photo_id', 'color_name')]
jv11_sub = unique(jv11_sub) 
dim(jv11_sub)
#[1] 1166759       2

write.table(jv11_sub, 'x11_jv_color_sets.tsv', sep = '\t', row.names = FALSE)
basket = read.transactions('x11_jv_color_sets.tsv', 
	format = 'single',
	cols = c(1, 2))

rules_x11 = apriori(basket,
                parameter = list(supp = 0.0001, 
                                 minlen = 2,
                                 conf = 0.0001, 
                                 target = 'rules'))
rules_x11 = as(rules_x11, "data.frame")

rules_x11$rules = gsub('\\{', '', rules_x11$rules)
rules_x11$rules = gsub('\\}', '', rules_x11$rules) 
rules_x11 = ddply(rules_x11,
             1,
             transform,
             lhs = strsplit(as.character(rules_x11), ' => ')[[1]][1],
             rhs = strsplit(as.character(rules_x11), ' => ')[[1]][2])

write.table(rules_x11, 'rules_x11.txt', sep = '\t', row.names = FALSE)


## Generate the recs because pandas sucks the d
catalog = read.delim('current_catalog_cleaned.txt', header = TRUE, sep = '\t')
color_x11 = read.delim('x11_all_with_headers.tsv', header = TRUE, sep = '\t')
trans = read.delim('leadership_trans.tsv', header = TRUE, sep = '\t', na.strings = '?')
trans$age_group = gsub(' ', '', trans$age_group)
leaders = read.delim('leadershiplist_1.16.14.txt', sep = '\t', header = TRUE)

custs = unique(trans[ , c('CUST_KEY', 'TRAN_KEY', 'BUS.DT', 'upc_desc', 'sku_idnt')])
custs = merge(custs, historical_catalog, by.x = 'sku_idnt', by.y = 'rms_sku_id')
custs = merge(custs, color_x11, by.x = 'sku_idnt', by.y = 'rms_sku_id', all.x = TRUE)
custs = merge(custs, leaders, by.x = 'CUST_KEY', by.y = 'CUSTKEY')
custs$age_group = gsub(' ', '', custs$age_group)
custs$description = gsub(' ', '', custs$description)
custs = custs[custs$age_group == 'A', ]
custs = custs[!(custs$description %in% bad_categories), ]
custs = custs[!(custs$description %in% bad_categories), ]
custs = arrange(custs, CUST_KEY, BUS.DT, TRAN_KEY)

# Remove items that do not match the customers sex
custs$sex = as.character(toupper(custs$sex))
custs$gender.x = as.character(toupper(custs$gender.x))
custs$gender.x = gsub(' ', '', custs$gender.x)
custs = custs[which(custs$sex == custs$gender.x), ]

write.table(custs, 'transactions.tsv', sep = '\t', row.names = FALSE)
custs = read.delim('transactions.tsv', sep = '\t', header = TRUE)

historical_catalog = read.delim('historical_product_catalog.txt', header = TRUE, sep = '\t')

active_catalog = read.delim('active_product_catalog.tsv', 
                            header = TRUE, 
                            sep = '\t',
                            na.strings = '?')

active_catalog = active_catalog[!(active_catalog$MERCHANDISING.CATEGORY.LEVEL1 %in% bad_categories), ]
active_catalog = active_catalog[!(active_catalog$MERCHANDISE.CATEGORY.LEVEL.2 %in% bad_categories), ]

active_catalog = unique(active_catalog)

# Merge with x11 colors
active_catalog = merge(active_catalog, color_x11, by.x = 'CHILD.SKU', by.y = 'rms_sku_id')

male_catalog = active_catalog[active_catalog$PRODUCT.GENDER == 'M' & active_catalog$PRODUCT.AGE == 'Adult' & active_catalog$ACTIVE.FLAG == 'Y', ]
female_catalog = active_catalog[active_catalog$PRODUCT.GENDER == 'F' & active_catalog$PRODUCT.AGE == 'Adult' & active_catalog$ACTIVE.FLAG == 'Y', ]

male_catalog = unique(male_catalog[ , c('STYLE.ID', 'HOSTED.URL', 'SKU.IMAGE.URL', 'GROUP.TITLE', 'PORTAL.DESCRIPTION', 'MERCHANDISE.CATEGORY.LEVEL.2', 'color_id', 'color_name', 'color_percent')])
female_catalog = unique(female_catalog[ , c('STYLE.ID', 'HOSTED.URL', 'SKU.IMAGE.URL', 'GROUP.TITLE', 'PORTAL.DESCRIPTION', 'MERCHANDISE.CATEGORY.LEVEL.2', 'color_id', 'color_name', 'color_percent')])

#save.image('generate_recs.RData')
load('generate_recs.RData')

custs_sub = unique(custs[ , c('CUST_KEY', 'color_id', 'color_name', 'sex')])

# Generate male recs
males = unique(custs_sub[custs_sub$sex == 'M', ])
males$sex = NULL
# Remove colors that aren't in the catalog
males = males[males$color_name != 'Medium Spring Green', ]
males = na.omit(males)

males$color_name = as.character(males$color_name)
male_catalog$color_name = as.character(male_catalog$color_name)
female_catalog$color_name = as.character(female_catalog$color_name)

male_chunks = split(unique(males$CUST_KEY), 1:10)

male_recs_1 = ddply(males[males$CUST_KEY %in% male_chunks[[1]], ],
             .(CUST_KEY, color_name),
             .progress = 'text', 
             transform,
             recs = generate_color_recs(color_name))

male_recs_out = merge(male_recs, leaders, by.x = 'CUST_KEY', by.y = 'CUSTKEY')
male_recs_out = arrange(male_recs_out, CUST_KEY, color_id, -recs.color_percent)
write.table(unique(male_recs_out), 'male_recs.txt', sep = '\t', row.names = FALSE)

# Generate female recs
females = unique(custs_sub[custs_sub$sex == 'F', ])
females$sex = NULL
# Remove colors that aren't in the catalog
females = females[females$color_name != 'Blue Violet', ]

females = na.omit(females)

females$color_name = as.character(females$color_name)
female_catalog$color_name = as.character(female_catalog$color_name)

female_chunks = split(unique(females$CUST_KEY), 1:12)

female_recs_1 = ddply(females[females$CUST_KEY %in% female_chunks[[1]], ],
             .(CUST_KEY, color_name),
             .progress = 'text', 
             transform,
             recs = generate_female_color_recs(color_name))

female_recs_out = merge(female_recs, leaders, by.x = 'CUST_KEY', by.y = 'CUSTKEY')
female_recs_out = arrange(female_recs_out, CUST_KEY, color_id, -recs.color_percent)
write.table(unique(female_recs_out), 'female_recs.txt', sep = '\t', row.names = FALSE)

generate_male_color_recs = function(color_name) {

  #catalog_sub = male_catalog[male_catalog$color_name == color_name & male_catalog$color_percent > 0.20, ]
  catalog_sub = male_catalog[male_catalog$color_name == color_name, ]

  return(catalog_sub[sample(nrow(catalog_sub), 10, replace = TRUE), ])

}

generate_female_color_recs = function(color_name) {

  #catalog_sub = male_catalog[male_catalog$color_name == color_name & male_catalog$color_percent > 0.20, ]
  catalog_sub = female_catalog[female_catalog$color_name == color_name, ]

  return(catalog_sub[sample(nrow(catalog_sub), 10, replace = TRUE), ])

}

########### Complementary Recs ###########
rules = read.delim('complementary_colors_full_x11.txt', 
                   header = TRUE, 
                   sep = '\t')

rules$rules = gsub('\\{', '', rules$rules)
rules$rules = gsub('\\}', '', rules$rules) 
rules = ddply(rules,
             1,
             transform,
             .progress = 'text',
             lhs = strsplit(rules, ' => ')[[1]][1],
             rhs = strsplit(rules, ' => ')[[1]][2])

color_clusters = unique(color_x11[ , c('color_id', 'color_name', 'rgb')])
color_clusters$rgb = gsub('{', '', color_clusters$rgb, fixed = TRUE)
color_clusters$rgb = gsub('}', '', color_clusters$rgb, fixed = TRUE)

## Construct rgb data frame to plot
temp = strsplit(color_clusters$rgb, ',')
temp = unlist(temp)
rgb = as.data.frame(matrix(temp, ncol = 3, byrow = TRUE))
colnames(rgb) = c('r', 'g', 'b')
rgb$r = as.numeric(as.character(rgb$r))
rgb$g = as.numeric(as.character(rgb$g))
rgb$b = as.numeric(as.character(rgb$b))
rgb$r_perc = rgb$r / 255
rgb$g_perc = rgb$g / 255
rgb$b_perc = rgb$b / 255

color_clusters = cbind(color_clusters, rgb)

mat = as.matrix(cbind(rgb$r, rgb$g, rgb$b))
rownames(mat) = color_clusters$color_name
colnames(mat) = c('r', 'g', 'b')

hc = hclust(dist(mat), "complete")

# Use around 20 clusters to start
rgb_scaled = scale(mat)
fit = kmeans(rgb_scaled, 30)
mat_with_clusters = data.frame(cbind(mat, fit$cluster))
colnames(mat_with_clusters) = c('r', 'g', 'b', 'cluster')
mat_with_clusters$color_name = rownames(mat)
mat_with_clusters = arrange(mat_with_clusters, cluster)

# Remove complicated rules
simple_rules = rules[!grepl(',', rules$rules), ]
cluster = mat_with_clusters[ , c('color_name', 'cluster')]

colnames(cluster) = c('color_name', 'rhs_cluster')
simple_rules = merge(simple_rules, cluster, by.x = 'rhs', by.y = 'color_name')
colnames(cluster) = c('color_name', 'lhs_cluster')
simple_rules = merge(simple_rules, cluster, by.x = 'lhs', by.y = 'color_name')

filtered_rules = simple_rules[-which(simple_rules$rhs_cluster == simple_rules$lhs_cluster), ]
filtered_rules = arrange(filtered_rules, lhs, -lift)
filtered_rules = ddply(filtered_rules,
                       .(lhs),
                       transform,
                       rankOrder = 1:length(lhs))
# Take only top four complements
filtered_rules = filtered_rules[filtered_rules$rankOrder < 5, ]

male_rules = merge(males, filtered_rules, by.x = 'color_name', by.y = 'lhs')
male_rules = arrange(male_rules, CUST_KEY, color_name, -lift)

male_chunks = split(unique(male_rules$CUST_KEY), 1:40)

male_rules = male_rules[male_rules$color_name != 'Hot Pink' & male_rules$color_name != 'Medium Spring Green', ]

male_results = list()
for (i in 1:length(male_chunks)) {


  male_results[[i]] = ddply(male_rules[male_rules$CUST_KEY %in% male_chunks[[i]], ],
               .(CUST_KEY, color_name, rhs),
               .progress = 'text', 
               transform,
               recs = generate_male_comp_color_recs(rhs))


}

male_comp_recs = do.call('rbind.fill', male_results)
male_comp_recs_out = merge(male_comp_recs, leaders, by.x = 'CUST_KEY', by.y = 'CUSTKEY')
male_comp_recs_out = arrange(male_comp_recs_out, CUST_KEY, color_id, -lift, -recs.color_percent)
write.table(unique(male_comp_recs_out), 'male_comp_recs.txt', sep = '\t', row.names = FALSE)

generate_male_comp_color_recs = function(color_name) {

  #catalog_sub = male_catalog[male_catalog$color_name == color_name & male_catalog$color_percent > 0.20, ]
  catalog_sub = male_catalog[male_catalog$color_name == color_name, ]

  return(catalog_sub[sample(nrow(catalog_sub), 1, replace = TRUE), ])

}

male_comp_recs_out = merge(male_comp_recs, leaders, by.x = 'CUST_KEY', by.y = 'CUSTKEY')
male_comp_recs_out = arrange(male_comp_recs_out, CUST_KEY, color_id, -lift, -recs.color_percent)
write.table(unique(male_comp_recs_out), 'male_comp_recs.txt', sep = '\t', row.names = FALSE)

# Female complementary recs
female_rules = merge(females, filtered_rules, by.x = 'color_name', by.y = 'lhs')
female_rules = arrange(female_rules, CUST_KEY, color_name, -lift)

female_chunks = split(unique(female_rules$CUST_KEY), 1:50)
female_chunks = split(unique(female_rules$CUST_KEY), 1:50)

female_comp_recs_29 = ddply(female_rules[female_rules$CUST_KEY %in% female_chunks[[29]], ],
             .(CUST_KEY, color_name, rhs),
             .progress = 'text', 
             transform,
             recs = generate_female_comp_color_recs(rhs))

write.table(female_comp_recs_30, 'female_comp_recs_30.txt', sep = '\t', row.names = FALSE)

female_comp_recs_out = merge(female_comp_recs, leaders, by.x = 'CUST_KEY', by.y = 'CUSTKEY')
female_comp_recs_out = arrange(female_comp_recs_out, CUST_KEY, color_id, -lift, -recs.color_percent)
write.table(unique(female_comp_recs_out), 'female_comp_recs_partial.txt', sep = '\t', row.names = FALSE)

generate_female_comp_color_recs = function(color_name) {

  #catalog_sub = male_catalog[male_catalog$color_name == color_name & male_catalog$color_percent > 0.20, ]
  catalog_sub = female_catalog[female_catalog$color_name == color_name, ]

  return(catalog_sub[sample(nrow(catalog_sub), 1, replace = TRUE), ])

}

dropped_ids = c(14028752, 15220542, 28854017, 29891869, 34615421, 3503657, 35499350, 4316354, 49747316, 50064899)
red = c(1366096)
lady_results = list()
for (i in 1:50) {


  lady_results[[i]] = ddply(female_rules[female_rules$CUST_KEY %in% female_chunks[[i]], ],
               .(CUST_KEY, color_name, rhs),
               .progress = 'text', 
               transform,
               recs = generate_female_comp_color_recs(rhs))

}

red = ddply(female_rules[female_rules$CUST_KEY %in% red, ],
             .(CUST_KEY, color_name, rhs),
             .progress = 'text', 
             transform,
             recs = generate_female_comp_color_recs(rhs))


out = do.call('rbind.fill', results)
female_comp_recs_out = merge(dropped_recs, leaders, by.x = 'CUST_KEY', by.y = 'CUSTKEY')
female_comp_recs_out = arrange(female_comp_recs_out, CUST_KEY, color_id, -lift, -recs.color_percent)
write.table(unique(female_comp_recs_out), 'female_comp_recs_missing.tsv', sep = '\t', row.names = FALSE, )

for (i in 1:10) {results[i] = i}

# Where the lhs_cluster == rhs_cluster throw out the rule
bad_categories = c(
  'Aquatic',
  'Aprons',
  'Baby Stroller/Car Seat/Carrier',
  'Backpack',
  'Bath Accessories',
  'Bath Additive/Aromatherapy',
  'Bathroom Accessories',
  'Bedding/Blanket',             
  'Bedding/Comforters', 
  'Bedding/Pillow',                   
  'Bedding/Sham', 
  'Bedding/Sheets',
  'Bib',
  'Book',
  'Booties',
  'Boxer',
  'Bra',
  'Braces',
  'Briefcase',
  'Brow',
  'Brush',
  'Camisole',
  'Candle',
  'Card Holders',             
  'Carpets/Rugs', 
  'Cases & Covers',
  'Cashmere brush', 
  'CD/Music',                          
  'Chair', 
  'Cheek',
  'Cleanser',                         
  'Clocks', 
  'Clog',
  'Clutch', 
  'Coin Purses',                      
  'Corkscrew', 
  'Cover-up',
  'Cup/Spoon/Feeding Accessories',
  'Decoration',                     
  'Diaper bag', 
  'DNU - Ceramics',                          
  'Dolls',
  'DVD/Video/Movie',                       
  'Earmuffs', 
  'Eye',
  'Eyewear Accessories',
  'Foundation',                         
  'Frames',
  'Gadget / Tool',
  'Games',                    
  'Garment bag',
  'Garter',         
  'Gift Set (BEAUTY ONLY)', 
  'Gift w/Purchase',
  'Gloves',
  'Goggles',
  'Gown', 
  'Gym bag',
  'Hair accessories',
  'Hand & Body',
  'Hooded towel',
  'Insoles',
  'Jewelry Box',
  'Jumper',                
  'Jumpsuit/Romper', 
  'Key Holders',                          
  'Laces', 
  'Laptop bag',                           
  'Lash', 
  'Lighting',                  
  'Lingerie wash', 
  'Lip',
  'Makeup application',                    
  'Makeup case', 
  'Messenger bag',                        
  'Messengerbag',
  'Mirrors', 
  'Miscellaneous',                        
  'Mittens', 
  'Moisturizer',
  'Nail care',                     
  'Nail Color', 
  'Napkins',
  'Nightgown',                         
  'Onesie', 
  'Organizer',                          
  'Other', 
  'Overall/Shortall',
  'Pajama bottom',                     
  'Pajama set', 
  'Panty/Brief',
  'Pantyhose/Nylons',                   
  'Pareo/sarong',
  'PDA case',                        
  'Perfume', 
  'Pet care',
  'Pin',
  'Polish',
  'Powder',
  'Robe',
  'Self tanner',                            
  'Set',
  'Shaper/Control',                   
  'Shaving case', 
  'Shaving Cream/Gel',
  'Shoe tree',
  'Sleeper',                           
  'Slip', 
  'Soap',
  'Sports Equipment',
  'Stationery/Cards',
  'Stockings',
  'Stuffed Animals',            
  'Suitcase (carry-on)', 
  'Suitcase (large)',                     
  'Sunglasses',
  'Swim bottom', 
  'Swim top',                     
  'Swim trunk', 
  'Swimsuit (complete)',
  'Table Placements',
  'Teddy',
  'Teething ring/Pacifier',
  'Thermal',
  'Throws',
  'Tights',
  'Toner',
  'Tote',            
  'Towel (Bath/Beach)', 
  'Tray (Decorative)',                          
  'Trunk', 
  'Umbrella',                     
  'Undershirt',
  'Visor',
  'Wallets',
  'Winecharm',                   
  'Winestoppers',
  'Albums/Scrapbooks', 
  'Bath Additive/Aromat',
  'Cologne',
  'Conditioners',
  'Hair styling product',
  'Herbal',
  'Lotion',
  'Makeup Remover',
  'Mask',
  'Scrub',
  'Shampoo',
  'Sunscreen')

bad_merch = c('Albums/Scrapbooks', 
  'Bath Accessories',
  'Bath Additive/Aromat',
  'Book',
  'Cologne',
  'Conditioners',
  'Hair styling product',
  'Herbal',
  'Lotion',
  'Makeup Remover',
  'Mask',
  'Scrub',
  'Shampoo',
  'Sunscreen')




