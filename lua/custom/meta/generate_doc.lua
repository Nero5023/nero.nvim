local doc_dir = '~/local_dev/buck2_doc'
doc_dir = vim.fn.expand(doc_dir)
vim.cmd '!buck2 docs starlark --format=markdown_files --markdown-files-destination-dir=" .. doc_dir ..  " --builtins prelude//docs:rules.bzl'
