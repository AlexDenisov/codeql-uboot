/**
 * @kind path-problem
 */

import cpp
import semmle.code.cpp.dataflow.TaintTracking
import DataFlow::PathGraph
 
class NetworkByteSwap extends Expr {
    NetworkByteSwap () {
      exists(MacroInvocation mi |
        mi.getExpr() = this and
        mi.getMacroName().regexpMatch("ntoh.*")
      )
    }
}
 
class Config extends TaintTracking::Configuration {
  Config() { this = "NetworkToMemFuncLength" }

  override predicate isSource(DataFlow::Node source) {
    source.asExpr() instanceof NetworkByteSwap
  }
  override predicate isSink(DataFlow::Node sink) {
    exists(FunctionCall fc|
      fc.getTarget().getName() = "memcpy" and
      fc.getArgument(2) = sink.asExpr()
    )
  }
}

from Config config, DataFlow::PathNode source, DataFlow::PathNode sink
where config.hasFlowPath(source, sink)
select sink.getNode(), source, sink, "Network byte swap flows to memcpy"