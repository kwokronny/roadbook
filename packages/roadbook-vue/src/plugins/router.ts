import { useStore } from "@/store";
import { createWebHashHistory, createRouter } from "vue-router";

const router = createRouter({
  history: createWebHashHistory(),
  routes: [
    {
      path: "/signin",
      component: () => import("../pages/auth/auth.vue"),
      children: [
        {
          path: "/signin",
          component: () => import("../pages/auth/components/SignIn.vue"),
          meta: {
            notAuth: true
          }
        },
        {
          path: "/signup",
          component: () => import("../pages/auth/components/SignUp.vue"),
          meta: {
            notAuth: true
          }
        },
      ],
    },
    {
      path: "/accept",
      component: () => import("../pages/accept.vue"),
      meta: {
        notAuth: true
      }
    },
    {
      path: "/travel",
      component: () => import("../pages/travel/index.vue"),
    },
    {
      path: "/travel/:id",
      component: () => import("../pages/travel/detail.vue"),
    },
    {
      path: "/travel/:id/batch",
      component: () => import("../pages/travel/batchEdit.vue"),
    },
    {
      path: "/:pathMatch(.*)*",
      redirect: "/travel",
    },
  ],
});

router.beforeEach((to, _form, next) => {
  const { token } = useStore();
  if (!token && to.meta?.notAuth !== true) {
    next('/signin');
  }
  next();
});

export default router;
