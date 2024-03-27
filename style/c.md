# Style guide for C
We started with the linux kernel style guide.


## Differences from the [Linux Kernel Styleguide](https://www.kernel.org/doc/html/v4.10/process/coding-style.html)
* 4 space tabs
* 80 preferred max linewidth, enforced max is 120.
* Pointer * goes next to type not name. (`uint8_t* foo`)
* Always use braces even for oneline stuff.
* Two newlines between functions
* Types: linux styleguide says dont' do `vps_t` instead of `struct virtual_container*`
  We don't do the pointer thing except to be opaque (as suggested by LSG) but we
  do typedef all out structs and enums.
* Our naming scheme is different
* Documentation is doxygen not kernel-doc


## Our Styleguide
### Stuff enforced by uncrustify
* 4 space tabs
  * Linux styleguide says 8, but we want to be lazy and allow more nesting inside a function
* 80 preferred max linewidth, enforced max is 120.
  * We want to be lazy and it's often easier to allow lines of like 100 chars than to have a semi-hard limit at 80
* Prefer `uint8_t` over `unsigned short`
  * Nobody can remember how big a `long` or a `long long` is, just specify.
* Pointer * goes next to type not name. (`uint8_t* foo`)
* Two newlines around function definitions/prototypes
* Follow [Linux Styleguide spaces](https://www.kernel.org/doc/html/v4.10/process/coding-style.html#spaces)
  for stuff like space between `if` and `(`, no spaces around `++`, etc.
* Braces: K&R: newline between function and open brace, no newline for non-functions
  * so like
    ```
    void foo()
    {
        if (stuff) {
            whatever;
        }
    }
    ```
    In the words of the [Linux Kernel Styleguide](https://www.kernel.org/doc/html/v4.10/process/coding-style.html)
    > Heretic people all over the world have claimed that this inconsistency is ... well ... inconsistent, but all right-thinking people know that (a) K&R are right and (b) K&R are right. Besides, functions are special anyway (you can’t nest them in C).

### The harder stuff not enforced by uncrustify

#### Line length
*Please* try to keep lines under 80 chars.

Uncrustify will enforce at 120 but we really want 80.

#### Naming

* `buf` not `buff`
* `buf_len`
* case for
  * function parameter: `snake_case`
  * global variable: `PascalCase`
  * local variable: `camelCase`
  * function names: `module[_subModule]_snake_case`
    * A module is a conceptual unit such as a library, or nordic src/core/sd.[ch]
  * type names: `snake_case_t`
  * enum_names: `snake_case_e`
  * filenames: `snake_case`
  * defines: `SCREAMING_SNAKE_CASE`

#### Comment Style
* Everything needs a brief description, a super concise intro to the function or whatever
  Use `@brief` for some things, `JAVADOC_AUTOBRIEF` will automatically brief everything else
  * use `@brief` for
    * functions
    * structs
    * defines
    * file headers
  * Justification: `@brief` is a visual marker some humans find helpful at the
    beginning of longer comment blocks to differentiate the first line
* Use Javadoc `@command` style for doxygen stuff instead of the default `\command`
  ```
  /**
   * @brief super concise brief
   *
   * A longer description if needed.
   */
  /** @brief whatever */
  ```
  * Justification: consistancy with nordic sdk
* Document struct members on the same line when possible, note the `<`
  ```
  /** @brief description */
  typedef struct {
      MessageFrame_t* mf; /**< J2735 MessageFrame struct */
      /**
       * something weird
       *
       * Lets pretend this one needs more description or it jjust can't fit on a single line
       */
      uin8_t thing;
  } whatever;
  ```
  * Justification: More readable if all the lines line up and don't alternate comments and struct members
* Outupt parameters should be documented
  ```
   * @param[out] out      output buffer for csv data
   * @param      data     data to encode
  ```
  * Justification: Differentiate output parameters but by default parameters are inputs
* Put function comments above declaration not definition
* C files get a max 50 char description at the top
* Function parmaeters that are altered should be marked @param[in,out] with a note saying how

#### Other style stuff
* Attribute goes after definition
  ```
  typedef struct {
    ...
  } __attribute__((packed)) whatever_t;
  ```
  * Justification: It doesn't matter so we picked one
* When multilining things like a ternary or boolean logic, put the operators at the start of the line
    ```
    #define whatever(foo) \
            foo \
            ? bar \
            : bat
    #define stuff(foo, bar) \
            ( foo \
            && bar)
    ```
  * Justification: More readable this way
* We want to try to strictly limit functions to 7 plus/minus two objects as per widly accepted work of George Miller
  * Justification: Make functions simple enough to reason about easily
* Output parameters go first
  * Justification: match standard functions like malloc, memcpy, etc
* Variable Declaration
  * One per line
  * Place a function's variables in the narrowest scope possible, and initialize variables in the declaration.

#### things to discuss
* What other things do we want to define here?



#### Things to check/change
* check that we never break up log strings for ease of grepping
* if function name is imperative return error code, if predicate return boolean
* don't duplicate types in callocs because that can lead to using the wrong type
  * `struct whatever* p = calloc(1, sizeof(*p));`
  instead of
  * `struct whatever* p = calloc(1, sizeof(struct whatever));`
* naming case

---

