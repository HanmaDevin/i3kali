-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("java").setup({
  jdk = {
    auto_install = false,
  },
})
require("lspconfig").jdtls.setup({
  settings = {
    java = {
      configuration = {
        runtimes = {
          {
            name = "JavaSE-21",
            path = "/opt/jdk-21",
            default = true,
          },
        },
        runtimes = {
          {
            name = "JavaSE-25",
            path = "/opt/jdk-25",
            default = true,
          },
        },
        runtimes = {
          {
            name = "JavaSE-17",
            path = "/opt/jdk-17",
            default = true,
          },
        },
      },
    },
  },
})
