\name{truelength}
\alias{truelength}
\alias{alloc.col}
\title{ Over-allocation access }
\description{
    These functions are experimental and somewhat advanced. By \emph{experimental} we mean their names might change and perhaps the syntax, argument names and types. So if you write a lot of code using them, you have been warned! They should work and be stable, though, so please report problems with them.
}
\usage{
truelength(x)
alloc.col(DT,
    n = getOption("datatable.alloccol"),        # default: quote(ncol(DT)+1024L)
    verbose = getOption("datatable.verbose"))   # default: FALSE
}
\arguments{
\item{x}{ Any type of vector, including \code{data.table} which is a \code{list} vector of column pointers. }
\item{DT}{ A \code{data.table}. }
\item{n}{ The number of column pointer slots to reserve in memory, including existing columns. May be a numeric, or a quote()-ed expression (see default). If \code{DT} is a 10 column \code{data.table}, \code{n=10000} means grow the spare slots from 1024 to 10000, assuming the default of 100 has not been changed.}
\item{verbose}{ Output status and information. }
}
\details{
    When adding columns by reference using \code{:=}, we \emph{could} simply create a new column list vector (one longer) and memcpy over the old vector, with no copy of the column vectors themselves. That requires negligibe use of space and time, and is what v1.7.2 did.  However, that copy of the list vector of column pointers only (but not the columns themselves), a \emph{shallow copy}, resulted in inconsistent behaviour in some circumstances. So, as from v1.7.3 data.table over allocates the list vector of column pointers so that columns can be added fully by reference, consistently.

    When the allocated column pointer slots are used up, to add a new column \code{data.table} must reallocate that vector. If two or more variables are bound to the same data.table this shallow copy may or may not be desirable, but we don't think this will be a problem very often (more discussion may be required on datatable-help). Setting \code{options(datatable.verbose=TRUE)} includes messages if and when a shallow copy is taken. To avoid shallow copies there are several options: use \code{\link{copy}} to make a deep copy first, use \code{alloc.col} to reallocate in advance, or, change the default allocation rule (perhaps in your .Rprofile); e.g., \code{options(datatable.alloccol=10000)}.

    Please note : over allocation of the column pointer vector is not for efficiency per se. It's so that \code{:=} can add columns by reference without a shallow copy.
}
\value{
    \code{truelength(x)} returns the length of the vector allocated in memory. \code{length(x)} of those items are in use. Currently, it's just the list vector of column pointers that is over-allocated (i.e. \code{truelength(DT)}), not the column vectors themselves, which would in future allow fast row \code{insert()}. For tables loaded from disk however, \code{truelength} is 0 in \R 2.14.0+ (and random in \R <= 2.13.2), which is perhaps unexpected. \code{data.table} detects this state and over-allocates the loaded \code{data.table} when the next column addition occurs. All other operations on \code{data.table} (such as fast grouping and joins) do not need \code{truelength}.
    
    \code{alloc.col} \emph{reallocates} \code{DT} by reference. This may be useful for efficiency if you know you are about to going to add a lot of columns in a loop. It also returns the new \code{DT}, for convenience in compound queries.
}
\seealso{ \code{\link{copy}} }
\examples{
DT = data.table(a=1:3,b=4:6)
length(DT)                 # 2 column pointer slots used
truelength(DT)             # 1026 column pointer slots allocated
alloc.col(DT,2048)
length(DT)                 # 2 used
truelength(DT)             # 2048 allocated, 2046 free
DT[,c:=7L]                 # add new column by assigning to spare slot
truelength(DT)-length(DT)  # 2045 slots spare
}
\keyword{ data }

