defmodule Autocontext.CallbackMock do
  import Mox

  Mox.defmock(Autocontext.CallbackBehaviourMock, for: Autocontext.CallbackBehaviour)
end
