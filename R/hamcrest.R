
### ----------------------------------------------------------------- ###
### ASSERTIONS ----
### ----------------------------------------------------------------- ###

#' Make a test assertion
#'
#' Use the \code{assertThat()} function to write your unit test. The first
#' argument is the result you want to test and the second argument is the
#' matcher that embodies the rule against which you want to test the result.
#'
#' @param actual object to be matched
#' @param matcher one of the matcher functions, see Details
#'
#' @details
#' The second argument \code{matcher} of assertThat should be a matcher
#' function. Matcher function returns a function which references the
#' \emph{expected value}. The \code{actual} value is passed to the resulting
#' matcher function.
#'
#' \itemize{
#'
#' \item \code{assertThat(actual, equalTo(expected))} checks that \code{actual}
#' is equal to (using the \code{==} comparison operator) \code{expected}. The
#' \code{equalTo()} matcher function can therefore also be used to compare
#' strings.
#'
#' \item \code{assertThat(actual, closeTo(expected, delta))} checks that
#' \code{actual} is \emph{close to} \code{expected} with a maximum allowed
#' difference of \code{delta}.
#'
#' \item \code{assertThat(actual, identicalTo(expected))} checks if
#' \code{actual} is \emph{identical} to (using the \code{\link{identical}}
#' function) \code{expected}.
#'
#' \item \code{assertThat(actual, isTrue())} and its shorthand
#' \code{assertTrue(value)} check that \code{actual} or \code{value} is
#' identical to \code{TRUE} (i.e. the logical vector or length 1). This is the
#' same as \code{assertThat(actual, identicalTo(TRUE))}. Use
#' \code{assertThat(actual, isFalse())} or \code{assertFalse(value)} to check if
#' \code{actual} or \code{value} are \code{FALSE}.
#'
#' \item \code{assertThat(actual, instanceOf(expected))} checks if \code{actual}
#' has class (using the \code{\link{inherits}} function) \code{expected}.
#'
#' }
#'
#' @examples \dontrun{
#' assertThat(-0.50557992900139, closeTo(-0.50557, delta = 1e4))
#' assertThat(floor(-1.5), identicalTo(-2))
#' assertThat(qnorm(0, 0, 1,  TRUE,  FALSE), equalTo(-Inf))
#' assertThat(is.integer(1L), isTrue())
#' assertThat(is.character(seq(10)), isFalse())
#' assertThat(log("a"), throwsError())
#' assertThat(any(range(2.0,3.0)), emitsWarning())
#' assertThat(1, not(identicalTo(2)))
#' }
#' @export
assertThat <- function(actual, matcher) {

  call <- match.call()

  matches <- tryCatch( matcher(actual), error = function(e) {
    stop(sprintf("\nassertThat(%s, %s) failed\nError: %s",
                 deparse0(call$actual), deparse0(call$matcher), deparse0(e$message)))
  })

  if(!matches) {
    stop(sprintf("\nassertThat(%s, %s) failed\nGot: %s",
                 deparse0(call$actual), deparse0(call$matcher), deparse0(actual)))
  }

  invisible(TRUE)
}

#' Assert that the value evaluates to true
#'
#' Asserts that the given \code{value} evaluates to \code{TRUE}. If the value
#' evaluates does not evaluate to \code{TRUE}, then an error condition is
#' raised.
#'
#' @param value a vector with any length.
#' @details
#' The \code{\link{identical}} function is used to check this condition,
#' so this function will also raise an error condition if \code{value} evaluates
#' to \code{0} or if the result of the evaluation has any attributes.
#'
#' @examples \dontrun{
#' assertTrue(is.numeric(2019))
#' assertThat(is.character("orange"), isTRUE)
#' }
#' @seealso
#' \itemize{
#' \item \code{\link{assertThat}}
#' \item \code{\link{assertFalse}}
#' \item \code{\link{isTrue}}
#' }
#' @export
assertTrue <- function(value) {

	call <- match.call()

	if(!identical(value, TRUE)) {
	  stopcall(value)
	}
}

#' Assert that the value evaluates to false
#'
#' Asserts that the given \code{value} evaluates to \code{FALSE}. If the value
#' evaluates does not evaluate to \code{FALSE}, then an error condition is
#' raised.
#'
#' @param value a vector with any length.
#' @details
#' The \code{\link{identical}} function is used to check this condition,
#' so this function will also raise an error condition if \code{value} evaluates
#' to \code{0} or if the result of the evaluation has any attributes.
#' @examples \dontrun{
#' assertFalse(is.character(1L))
#' ## If you use an R version greater than 3.5.0, you can also use:
#' assertThat(is.numeric("a"), isFALSE)
#' }
#' @seealso
#' \itemize{
#' \item \code{\link{assertThat}}
#' \item \code{\link{assertTrue}}
#' \item \code{\link{isFalse}}
#' }
#' @export
assertFalse <- function(value) {

	call <- match.call()

	if(!identical(value, FALSE)) {
	  stopcall(value)
	}
}

### ----------------------------------------------------------------- ###
### MATCHERS ----
### ----------------------------------------------------------------- ###

#' Returns a function that checks whether its \emph{argument} is close to an
#' \emph{expected} result within the given tolerance
#'
#' @param expected a numeric vector.
#' @param delta a numeric vector of length one that defines the maximum allowed
#'   difference.
#' @details
#' The \code{closeTo()} matcher function can only be used for numeric arguments.
#' @examples \dontrun{
#' assertThat(-0.50557992900139, closeTo(-0.50557, delta = 1e4))
#' }
#' @seealso
#' \itemize{
#' \item \code{\link{identicalTo}}
#' \item \code{\link{equalTo}}
#' }
#' @export
closeTo <- function(expected, delta) {
    stopifnot(is.numeric(expected) & is.numeric(delta) & length(delta) == 1L)
	function(actual) {
		length(expected) == length(actual) &&
				all(abs(expected-actual)<delta)
	}
}

#' Returns a function that checks whether its \emph{argument} is identical to an
#' \emph{expected} result
#'
#' @param expected object passed to the matcher function.
#' @param tol numeric tolerance. Should note that \code{tol} is only used if the
#'   expected value is a finite floating point number. If the expected value is
#'   another type, such as an integer, an exact match is expected.
#'
#' @examples \dontrun{
#' assertThat(floor(-1.5), identicalTo(-2))
#' }
#' @seealso
#' \itemize{
#' \item \code{\link{closeTo}}
#' \item \code{\link{equalTo}}
#' }
#' @export
identicalTo <- function(expected, tol = NULL) {
	tolMissing <- missing(tol)
	function(actual) {
	    identical.rec(actual, expected, tol)
	}
}

#' Returns a function that checks whether its \emph{argument} is equal to an
#' \emph{expected} result
#'
#' @param expected object passed to the matcher function.
#' @examples \dontrun{
#' assertThat(qnorm(0, 0, 1, TRUE, FALSE), equalTo(-Inf))
#' assertThat(length(rnorm(10)), equalTo(10))
#' }
#' @seealso
#' \itemize{
#' \item \code{\link{identicalTo}}
#' \item \code{\link{closeTo}}
#' }
#' @export
equalTo <- function(expected) {
  function(actual) {
    if (is.list(actual))
      equal.rec(actual, expected)
    else
      length(actual) == length(expected) && all(actual == expected)
  }
}

#' Returns a function that checks whether its \emph{argument} deparses to an
#' \emph{expected} result
#'
#' Deparsing transforms unevaluated expressions into character vectors.
#'
#' @param expected object passed to the matcher function.
#' @examples \dontrun{
#' assertThat(unlist(quote(sin(3.14)), recursive = FALSE), deparsesTo("sin(3.14)"))
#' }
#' @export
deparsesTo <- function(expected) {
    function(actual) {
        identical(paste(deparse(actual), collapse=""), expected)
    }
}

#' Returns a function that checks whether its \code{argument} is instance of an
#' \emph{expected} result
#'
#' Checks if the value is an instance of a class. The expected value checks
#' where the class name of the actual object is inherited. This is about
#' checking S3 and S4 classes and the call uses the base function
#' \code{\link{inherits}}.
#'
#' @param expected object passed to the matcher function.
#' @examples \dontrun{
#' res <- lm(Petal.Length ~ Petal.Width, iris)
#' assertThat(res, instanceOf("lm"))
#'
#' df <- data.frame(x = c(1, 1, 1, 2, 2, 3, 3), y = c(1, 2, 3, 4, 5, 6, 7))
#' res <- by(df$y, df$x, sum)
#' assertThat(res, instanceOf("by"))
#'
#' class(df) <- "result"
#' assertThat(df, instanceOf("result"))
#' }
#' @export
instanceOf <- function(expected) {
    function(actual) {
        inherits(actual, expected)
    }
}

#' Returns a function that checks whether its \emph{argument} is 'TRUE'
#'
#' @examples \dontrun{
#' assertThat(is.integer(1L), isTrue())
#' }
#' @seealso
#' \itemize{
#' \item \code{\link{assertTrue}}
#' \item \code{\link{assertFalse}}
#' \item \code{\link{isFalse}}
#' }
#' @export
isTrue <- function() {
    function(actual) {
        identical(TRUE, actual)
    }
}

#' Returns a function that checks whether its \emph{argument} is 'FALSE'
#'
#' @examples \dontrun{
#' assertThat(is.character(seq(10)), isFalse())
#' }
#' @seealso
#' \itemize{
#' \item \code{\link{assertTrue}}
#' \item \code{\link{assertFalse}}
#' \item \code{\link{isTrue}}
#' }
#' @export
isFalse <- function() {
    function(actual) {
        identical(FALSE, actual)
    }
}

#' Returns a function that checks whether its \emph{argument} throws (any) error
#'
#' @examples \dontrun{
#' assertThat(log("a"), throwsError())
#' }
#' @seealso
#' \itemize{
#' \item \code{\link{emitsWarning}}
#' }
#' @export
throwsError <- function() {
	function(actual) {
		result <- tryCatch( force(actual), error = function(e) e )
		return(inherits(result, "error"))
	}
}

#' Returns a function that checks whether its \emph{argument} emits warning(s)
#'
#' @examples \dontrun{
#' assertThat(any(range(2.0,3.0)), emitsWarning())
#' }
#' @seealso
#' \itemize{
#' \item \code{\link{throwsError}}
#' }
#' @export
emitsWarning <- function() {
	function(actual) {
		result <- tryCatch( force(actual), warning = function(e) e )
		return(inherits(result, "warning"))
	}
}

### ----------------------------------------------------------------- ###
### OTHERS ----
### ----------------------------------------------------------------- ###

#' Negates the result of a matcher function
#'
#' @param matcher one of the matcher functions, see Details of
#'   \code{\link{assertThat}}.
#' @examples \dontrun{
#' assertThat(1, not(identicalTo(2)))
#' }
#' @export
not <- function(matcher) {
	function(actual) {
		return(!matcher(actual))
	}
}

#' A testing suite for hamcrest tests
#'
#' The tests put in this suite will be evaluated in a local environment. It is
#' suitable to run hamcrest tests without being bothered by the global
#' namespace.
#'
#' @param note an explanatory text for the tests.
#' @param ... hamcrest assertions.
#'
#' @export
testHamcrest <- function(note, ...) {
  stopifnot(is.character(note) && length(note) == 1L)
  message(sprintf("Testing '%s' ...", note))
  dots <- list(...)
  invisible(local(dots))
  message("Success!")
}

