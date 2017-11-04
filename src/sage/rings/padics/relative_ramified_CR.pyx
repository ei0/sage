include "sage/libs/linkages/padics/Polynomial_ram.pxi"
include "CR_template.pxi"

cdef class RelativeRamifiedCappedRelativeElement(CRElement):
    def __cinit__(self, parent=None, x=None, absprec=infinity, relprec=infinity):
        # It's not possible to set self.unit in cconstruct (because of the calling syntax)
        # so we do it here.
        cdef type t
        if parent is not None:
            t = type((<PowComputer_?>parent.prime_pow).modulus)
            self.unit = t.__new__(t)

    cdef CRElement _new_c(self):
        """
        Creates a new element in this ring.

        This is meant to be the fastest way to create such an element; much
        faster than going through the usual mechanisms which involve
        ``__init__``.

        TESTS::

            sage: R.<a> = ZqCR(25)
            sage: S.<x> = ZZ[]
            sage: W.<w> = R.ext(x^2 - 5)
            sage: w * (w+1) #indirect doctest

        """
        cdef type t = type(self)
        cdef type polyt = type(self.prime_pow.modulus)
        cdef CRElement ans = t.__new__(t)
        ans._parent = self._parent
        ans.prime_pow = self.prime_pow
        ans.unit = polyt.__new__(polyt)
        cconstruct(ans.unit, ans.prime_pow)
        return ans

    def __reduce__(self):
        """
        Return a tuple of a function and data that can be used to unpickle this
        element.

        EXAMPLES::

            sage: R.<a> = ZqCR(9)
            sage: S.<x> = ZZ[]
            sage: W.<w> = R.extension(x^2 - 3)
            sage: loads(dumps(w)) == w
            True
        """
        return unpickle_cre_rel_v2, (self.__class__, self.parent(), cpickle(self.unit, self.prime_pow), self.ordp, self.relprec)

    def _poly_rep(self):
        return self.unit

def unpickle_cre_rel_v2(cls, parent, unit, ordp, relprec):
    """
    Unpickles a capped relative element.

    EXAMPLES::

        sage: from sage.rings.padics.relative_ramified_CR import RelativeRamifiedCappedRelativeElement, unpickle_cre_rel_v2
        sage: R.<a> = ZqCR(9)
        sage: S.<x> = ZZ[]
        sage: W.<w> = R.extension(x^2 - 3)
        sage: u = unpickle_cre_rel_v2(RelativeRamifiedCappedRelativeElement, W, [a, 1]); u
        sage: u.parent() is W
        True
    """
    cdef RelativeRamifiedCappedRelativeElement ans = cls.__new__(cls)
    ans._parent = parent
    ans.prime_pow = <PowComputer_?>parent.prime_pow
    cdef type polyt = type(ans.prime_pow.modulus)
    ans.unit = polyt.__new__(polyt)
    cconstruct(ans.unit, ans.prime_pow)
    cunpickle(ans.unit, unit, ans.prime_pow)
    ans.ordp = ordp
    ans.relprec = relprec
    return ans
