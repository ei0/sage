from sage.rings.polynomial.polynomial_element cimport Polynomial_generic_dense_inexact as celement
from sage.rings.padics.pow_computer_relative cimport PowComputer_relative_eis as PowComputer_

include "CA_template_header.pxi"

cdef class RelativeRamifiedCappedAbsoluteElement(CAElement):
    pass
