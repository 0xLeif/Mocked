/**
 Represents different levels of access control for declarations in Swift.

 Access levels determine which parts of your code can access a declaration.
 Swift provides several levels of access: `open`, `public`, `package`, `internal`, `fileprivate`, and `private`.
 Each level restricts or permits access in increasing order of specificity.

 - `open`: The most permissive access level, allowing a declaration to be used and subclassed
   within the module it’s defined in and by other modules that import it. Use `open` when you
   want code outside the module to subclass or override entities.

 - `public`: Allows a declaration to be used by other modules but restricts subclassing
   and overriding to within the defining module. Use `public` when exposing functionality
   that should not be subclassed or overridden by external modules.

 - `package`: Limits access to declarations within the same package, making them inaccessible
   outside the package's scope. This is ideal for managing code visibility within related
   modules that are distributed together.

 - `internal`: Default access level in Swift. Declarations are accessible within the same
   module but are hidden from external modules. This is ideal for exposing code internally
   without making it available to other modules.

 - `private`: Restricts access to the enclosing declaration (such as a type or extension).
   Declarations marked as `private` are inaccessible outside the enclosing scope, providing
   the highest level of encapsulation.

 - `fileprivate`: Allows access within the same file only. Unlike `private`, `fileprivate`
   allows access to declarations across types and extensions within a single file, providing
   a middle ground between `internal` and `private`.
 */
public enum AccessLevel: String {
    case `open`
    case `public`
    case `package`
    case `internal`
    case `private`
    case `fileprivate`
}
