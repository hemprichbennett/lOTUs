line_plot <- function(df, dataset, clustering, metric, value, plotname = NULL){
  rankings_mat <- matrix(nrow = length(unique(df$dataset)), ncol = length(unique(df$clustering)))
  colnames(rankings_mat) <- unique(df$clustering)
  ms <- as.character(c())
  clusts <- c()
  ns <- c()
  for(i in 1:length(unique(df$metric))){
    #for(i in 1:1){

    met <- unique(df$metric)[i]
    metric_subset <- df[which(df$metric==met),]
    #Make the appropriate subset of the data to play with
    for(a in 1:length(unique(metric_subset$clustering))){
      clust <- unique(metric_subset$clustering)[a]
      #print(clust)
      metric_and_cluster_subset <- metric_subset[which(metric_subset$clustering==clust),]
      rankings_mat[,a] <- metric_and_cluster_subset[order(metric_and_cluster_subset$value),'dataset']
    }

    for(b in 1:ncol(rankings_mat)){#Starting from 2 as we have to calculate the similarity to the previous col
      cl <- as.numeric(colnames(rankings_mat)[b])
      if(b==1){##We need to do this step as otherwise our counting backwards will crash things: we want to see how similar the values are to the value before them, which is confusing for the first value in the loop
        n <- 7
      }else{
        n <- length(which(rankings_mat[,(b-1)]==rankings_mat[,b]))
      }

      ns <- c(ns,n)

      clusts <- c(clusts, cl)
      ms <- c(ms, as.character(met))
    }
  }

  out_df <- data.frame(ms, clusts, ns)
  #print(out_df)
  #return(out_df)
  out_df <- out_df[order(out_df$ms, decreasing = TRUE),]

  # plot
  # set x limits
  xmin <- 91
  xmax <- 98
  my_rows <- length(unique(out_df$ms))
  my_rows
  #pdf('../Figures/reliable_range_bars.pdf')
  # empty plot
  par(mar=c(5,12,2.5,3))
  plot(1,type="n",xlim=c(xmin,xmax),ylim=c(0,my_rows+1),axes=TRUE,xlab="clustering (%)", yaxt="n", ylab="",frame=FALSE)
  title(main = plotname)
  axis(2, at=1:length(unique(out_df$ms)), labels=unique(out_df$ms), las = 1, cex.axis=0.65)
  #for(a in 1:2){
  for(a in 1:length(unique(out_df$ms))){
    met <- unique(out_df$ms)[a]
    #print(met)
    connectance_df <- out_df[which(out_df$ms == met),]
    connectance_df$ms <- NULL
    # dummy data
    matches <- sample(0:2,100,replace=TRUE)
    thresholds <- seq(90,100,length=100)
    cbind(thresholds,matches)



    # which entries do we wish to count?
    test <- rep(0,nrow(connectance_df))
    #df <- data.frame(thresholds,matches)
    test[which(connectance_df$ns>6)] <- 1
    df <- data.frame(connectance_df,test)

    #add dummy entries to ensure we pick up the correct start and end points
    df <- rbind(c(0,0,0),df)
    df <- rbind(df,c(0,0,0))

    # look for starts and stops, ensuring we pick up single points
    start_stop <- rep(NA,nrow(df))
    for(i in 2:nrow(df)){
      # start points
      ifelse(df$test[i]==1 & df$test[i-1]==0, start_stop[i] <- "start", start_stop[i] <- "NA")
    }
    # end points
    for(i in 1:(nrow(df)-1))
    {
      if(df$test[i]==1 & df$test[i+1]==0) start_stop[i] <- "stop"
    }
    # single points
    for(i in 2:(nrow(df)))
    {
      if(df$test[i]==1 & df$test[i+1]==0 & df$test[i-1]==0) start_stop[i] <- "single"
    }
    #For the crap bits
    for(i in 1:(nrow(df)-1))
    {
      if(df$test[i]==0) start_stop[i] <- "crap"
    }

    # add to dataframe
    df <- data.frame(df,start_stop)

    # extract start and end points of each sequence
    line_starts <- subset(df,df$start_stop=="start")[,1]
    line_stops <- subset(df,df$start_stop=="stop")[,1]
    bad_points <- subset(df,df$start_stop=="crap")[,1]
    single_points <- subset(df,df$start_stop=='single')[,1]
    line_ends <- cbind(line_starts,line_stops)
    line_ends <- rbind(line_ends, cbind(bad_points, bad_points))
    line_ends <- rbind(line_ends, cbind(single_points, single_points))
    if(0.0 %in% line_ends[,1]){
      line_ends <- line_ends[-which(line_ends[,1]==0.0),] # Remove the zero values which we'd put in earlier when generating df
    }

    line_ends

    #These rows aren't in order yet, which would allow us to plot but would mess up the colour scheme. The below line sorts that
    if(!is.null(nrow(line_ends))){
      line_ends <- line_ends[order(line_ends[,1]),]
    } #We need the if statement as some lines are nice and have one value throughout, but that means we cannot order their rows as they don't really have any



    #I've now made the empty plot before initiating the loop
    # guideline
    #lines(matrix(c(xmin,xmax,a,a),ncol=2,byrow=FALSE),lwd=0.5,col="red")

    # add lines showing matches
    if(is.null(nrow(line_ends))){
      lines(matrix(c(line_ends[1],line_ends[2],a,a),ncol=2,byrow=FALSE),lwd=3,col='black')
    }
    else if(nrow(line_ends>0)){ #Some of the metrics have zero lines, as they're so utterly shit.
      #The if statement lets us skip them, as otherwise they crash it

      for(i in 1:nrow(line_ends))
      {
        lines(matrix(c(line_ends[i,1],line_ends[i,2],a,a),ncol=2,byrow=FALSE),lwd=3,col='black')
        #print(i)
      }

    }

  }
  abline(v=c(93,97),lty=2,col="gray")

}