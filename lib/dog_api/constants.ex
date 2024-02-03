defmodule DogAPI.Wrapper.Constants do
  @moduledoc """
  Module defines a struct which represents the data defined by the result schema.

  JSON format

  """

  @name __MODULE__
  #@timenow to_string(Date.utc_today)
  @excepts [enum_cheat: "pages.cheatsheets.enum-cheat"]
  @constants [
    code_anti_patterns: "pages.anti-patterns.code-anti-patterns",
    design_anti_patterns: "pages.anti-patterns.design-anti-patterns",
    macro_anti_patterns: "pages.anti-patterns.macro-anti-patterns",
    process_anti_patterns: "pages.anti-patterns.process-anti-patterns",
    what_anti_patterns: "pages.anti-patterns.what-anti-patterns",
    alias_require_and_import: "pages.getting-started.alias-require-and-import",
    anonymous_functions: "pages.getting-started.anonymous-functions",
    basic_types: "pages.getting-started.basic-types",
    binaries_strings_and_charlists: "pages.getting-started.binaries-strings-and-charlists",
    case_cond_and_if: "pages.getting-started.case-cond-and-if",
    comprehensions: "pages.getting-started.comprehensions",
    debugging: "pages.getting-started.debugging",
    enumerable_and_streams: "pages.getting-started.enumerable-and-streams",
    erlang_libraries: "pages.getting-started.erlang-libraries",
    introduction: "pages.getting-started.introduction",
    io_and_the_file_system: "pages.getting-started.io-and-the-file-system",
    keywords_and_maps: "pages.getting-started.keywords-and-maps",
    lists_and_tuples: "pages.getting-started.lists-and-tuples",
    module_attributes: "pages.getting-started.module-attributes",
    modules_and_functions: "pages.getting-started.modules-and-functions",
    optional_syntax: "pages.getting-started.optional-syntax",
    pattern_matching: "pages.getting-started.pattern-matching",
    processes: "pages.getting-started.processes",
    protocols: "pages.getting-started.protocols",
    recursion: "pages.getting-started.recursion",
    sigils: "pages.getting-started.sigils",
    structs: "pages.getting-started.structs",
    try_catch_and_rescue: "pages.getting-started.try-catch-and-rescue",
    writing_documentation: "pages.getting-started.writing-documentation",
    domain_specific_languages: "pages.meta-programming.domain-specific-languages",
    macros: "pages.meta-programming.macros",
    quote_and_unquote: "pages.meta-programming.quote-and-unquote",
    agents: "pages.mix-and-otp.agents",
    config_and_releases: "pages.mix-and-otp.config-and-releases",
    dependencies_and_umbrella_projects: "pages.mix-and-otp.dependencies-and-umbrella-projects",
    distributed_tasks: "pages.mix-and-otp.distributed-tasks",
    docs_tests_and_with: "pages.mix-and-otp.docs-tests-and-with",
    dynamic_supervisor: "pages.mix-and-otp.dynamic-supervisor",
    erlang_term_storage: "pages.mix-and-otp.erlang-term-storage",
    genservers: "pages.mix-and-otp.genservers",
    introduction_to_mix: "pages.mix-and-otp.introduction-to-mix",
    supervisor_and_application: "pages.mix-and-otp.supervisor-and-application",
    task_and_gen_tcp: "pages.mix-and-otp.task-and-gen-tcp",
    compatibility_and_deprecations: "pages.references.compatibility-and-deprecations",
    library_guidelines: "pages.references.library-guidelines",
    naming_conventions: "pages.references.naming-conventions",
    operators: "pages.references.operators",
    patterns_and_guards: "pages.references.patterns-and-guards",
    syntax_reference: "pages.references.syntax-reference",
    typespecs: "pages.references.typespecs",
    unicode_syntax: "pages.references.unicode-syntax"


  ]
  @status_map %{
    :approve => "approve",
    :disapprove => "disapprove",
    :refer => "refer_to_mentor"
  }

  @enforce_keys [:analysis_module, :code_file, :code_path, :path]
  defstruct [
    analysis_module: nil,
    analyzed: false,
    code: nil,
    code_file: nil,
    code_path: nil,
    comments: [],
    final: false,
    halted: false,
    path: nil,
    status: nil
  ]

  for {constant, markdown} <- @constants do
    def unquote(constant)(), do: unquote(markdown)
  end

  def list_of_all_comments() do
    Enum.map(@constants, &Kernel.elem(&1, 1))
  end

  def list_of_all_excepts() do
    Enum.map(@excepts, &Kernel.elem(&1, 1))
  end

  def status, do: @status_map

  def to_json(r = %@name{}) do
    Jason.encode!(%{status: @status_map[r.status], comments: r.comments})
  end
end
