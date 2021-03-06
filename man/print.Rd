% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/conceptlist.R
\name{print.conceptlist}
\alias{print.conceptlist}
\title{Print a list of concepts}
\usage{
\method{print}{conceptlist}(x, ...)
}
\arguments{
\item{x}{A list of concepts as a result of subsetting a \code{ConceptLattice}}

\item{...}{Another (unused) arguments.}
}
\value{
Nothing, just prints a list of concepts nicely.
}
\description{
Print a list of concepts
}
\examples{
# Build a formal context
fc_planets <- FormalContext$new(planets)

# Find its concepts
fc_planets$find_concepts()

# Print the first 3 concepts
fc_planets$concepts[1:3]

}
